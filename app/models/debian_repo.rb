require 'net/http'
require 'xz'
require 'gzip'

class DebianRepo < Repo
	def self.type_name
		"deb"
	end

	def fetch
		self.last_fetch = DateTime.now
		self.save

		clear_fetch_log
		start_time = Time.now

		self.log_fetch "Reading repo url...\n"
		url_parts = url.split

		release = Hash.new
		packages_name = Array.new
		packages_version = Array.new
		packages_arch = Array.new
		packages_description = Array.new
		packages_conflict_name = Array.new
		packages_conflict_version = Array.new
		packages_conflict_arch = Array.new
		packages_conflict_description = Array.new

		self.log_fetch "\nOpening persistant connection to repo server..."
		Net::HTTP.start(URI(url_parts[0]).host, URI(url_parts[0]).port) do |http|
			self.log_fetch "OK\n"

			self.log_fetch "Fetching Release file for #{url_parts[2]}..."
			release_start_time = Time.now
			release_res = http.request Net::HTTP::Get.new URI("#{url_parts[0]}/dists/#{url_parts[1]}/Release")
			if !(release_res.is_a? Net::HTTPSuccess)
				self.log_fetch "FAIL, [#{release_res.code} #{release_res.msg}]\n\n[Error] Unable to fetch Release file!"
				return false
			end

			release_end_time = Time.now
			self.log_fetch "OK, fetched in #{((release_end_time - release_start_time) * 100).ceil / 100.0} sec\n"
			
			self.log_fetch "\nReading Release file...\n"
			release_body = release_res.body.force_encoding("UTF-8")
			release[:version] = release_body[/\nVersion: ([0-9.]+)\n/, 1].to_f
			release[:date] = DateTime.parse(release_body[/\nDate: (.*)\n/, 1])
			release[:arch] = release_body[/\nArchitectures: (.*)\n/, 1].split
			release[:components] = release_body[/\nComponents: (.*)\n/, 1].split

			self.log_fetch "version: #{release[:version].to_s}\ndate: #{release[:date]}\narch: #{release[:arch]}\ncomponents: #{release[:components]}\n"

			if !(release[:components].include? url_parts[2])
				self.log_fetch "\n[Error] Component '#{url_parts[2]}' not found in release file!"
				return false
			end

			#if (self.fetch_last_version != nil && self.fetch_last_version == release[:version]) && (self.fetch_last_date != nil && (self.fetch_last_date <=> release[:date]) == 0)
			#	self.log_fetch "\n[Done] Already up to date. Nothing to do."
			#	self.fetch_info = {new: 0, updated: 0, updated_conflicts: [], not_updated: Packages.all.length, removed: []}
			#	self.save
			#	return true
			#end

			self.log_fetch "\nChecking if repo supports binary-all..."
			check_start_time = Time.now
			binary_all_res = http.request Net::HTTP::Get.new URI("#{url_parts[0]}/dists/#{url_parts[1]}/#{url_parts[2]}/binary-all/")
			if !(binary_all_res.is_a? Net::HTTPSuccess) and binary_all_res.code != 404
				self.log_fetch "FAIL, [#{binary_all_res.code} #{binary_all_res.msg}]\n\n[Error] Unable to check if repo supports binary-all!"
				return false
			elsif binary_all_res.code == 404
				self.log_fetch "DOES NOT\n"
			else
				check_end_time = Time.now
				self.log_fetch "OK, fetched in #{((check_end_time - check_start_time) * 100).ceil / 100.0} sec\n"
				release[:arch] << "all"
			end

			self.log_fetch "Fetching package lists for #{url_parts[2]}:\nWhitelisted architectures: #{Package.arch_whitelist}\n"
			release[:arch].each do |arch|
				if Package.arch_whitelist.include? arch
					self.log_fetch "\nFetching binary-#{arch}..."

					fetch_start_time = Time.now
					if !(arch_res = http.request Net::HTTP::Get.new URI("#{url_parts[0]}/dists/#{url_parts[1]}/#{url_parts[2]}/binary-#{arch}/Packages.xz"))
						self.log_fetch "FAIL, [#{binary_all_res.code} #{binary_all_res.msg}]\nFetching gz archive instead..."

						if !(arch_res = http.request Net::HTTP::Get.new URI("#{url_parts[0]}/dists/#{url_parts[1]}/#{url_parts[2]}/binary-#{arch}/Packages.xz"))
							self.log_fetch "FAIL, [#{binary_all_res.code} #{binary_all_res.msg}]\n\n[Error] Unable to fetch package list for binary-#{arch}!"
							return false
						else
							self.log_fetch "OK\n"
							arch_compression_method = "gzip"
						end
					else
						fetch_end_time = Time.now
						self.log_fetch "OK, fetched in #{((fetch_end_time - fetch_start_time) * 100).ceil / 100.0} sec\n"
						arch_compression_method = "xz"
					end

					if arch_compression_method == "xz"
						self.log_fetch "Decompressing package list with xz..."
						arch_package_list = XZ.decompress(arch_res.body).force_encoding("UTF-8")
						self.log_fetch "OK\n"
					elsif arch_compression_method == "gzip"
						self.log_fetch "Decompressing package list with gzip..."
						arch_package_list = arch_res.body.gunzip.force_encoding("UTF-8")
						self.log_fetch "OK\n"
					end

					self.log_fetch "Reading package list..."

					read_start_time = Time.now
					current_pkg_name = ""
					current_pkg_ver = ""
					current_pkg_arch = ""
					current_pkg_desc = ""
					num_packages = 0
					num_conflicts = 0
					lines = arch_package_list.split("\n")
					num_lines = lines.length.to_f
					line_count = 0
					progress = [false, false, false, false, false, false, false, false, false]
					lines.each do |line|
						if line[0..7] == "Package:"
							current_pkg_name = line[9..line.length]
						elsif line[0..7] == "Version:"
							current_pkg_ver = line[9..line.length]
						elsif line[0..12] == "Architecture:"
							current_pkg_arch = line[14..line.length]
						elsif line[0..11] == "Description:"
							current_pkg_desc = line[13..line.length]
						elsif line == ""
							found_conflict = false
							packages_name.each_index do |i|
								if packages_name[i] == current_pkg_name && (packages_arch[i] == current_pkg_arch && packages_version[i] != current_pkg_ver)
									packages_conflict_name << current_pkg_name
									packages_conflict_version << current_pkg_ver
									packages_conflict_arch << current_pkg_arch
									packages_conflict_description << current_pkg_desc
									found_conflict = true
									num_conflicts += 1
								end
							end

							if !found_conflict
								packages_name << current_pkg_name
								packages_version << current_pkg_ver
								packages_arch << current_pkg_arch
								packages_description << current_pkg_desc
								num_packages += 1
							end
						end

						if !progress[0] && (line_count / num_lines) >= 0.1
							self.log_fetch "10%..."
							progress[0] = true
						elsif !progress[1] && (line_count / num_lines) >= 0.2
							self.log_fetch "20%..."
							progress[1] = true
						elsif !progress[2] && (line_count / num_lines) >= 0.3
							self.log_fetch "30%..."
							progress[2] = true
						elsif !progress[3] && (line_count / num_lines) >= 0.4
							self.log_fetch "40%..."
							progress[3] = true
						elsif !progress[4] && (line_count / num_lines) >= 0.5
							self.log_fetch "50%..."
							progress[4] = true
						elsif !progress[5] && (line_count / num_lines) >= 0.6
							self.log_fetch "60%..."
							progress[5] = true
						elsif !progress[6] && (line_count / num_lines) >= 0.7
							self.log_fetch "70%..."
							progress[6] = true
						elsif !progress[7] && (line_count / num_lines) >= 0.8
							self.log_fetch "80%..."
							progress[7] = true
						elsif !progress[8] && (line_count / num_lines) >= 0.9
							self.log_fetch "90%..."
							progress[8] = true
						end

						line_count = line_count + 1
					end

					read_end_time = Time.now
					self.log_fetch "OK, read in #{((read_end_time - read_start_time) * 100).ceil / 100.0} sec\n"
					self.log_fetch "Fetched #{num_packages} packages with #{num_conflicts} conflicts...\n"
				end
			end
		end

		# update repo
		self.log_fetch "\nUpdating package database...\n"
		num_new_pkgs = 0
		num_updated_pkgs = 0
		num_not_updated_pkgs = 0
		updated_conflicts_pkgs = Array.new
		removed_pkgs = Array.new

		# process conflicts first so they don't get created/updated w/o user confirm
		self.log_fetch "Processing package conflicts...\n"
		packages_conflict_name.each_index do |i|
			j = nil
			packages_name.each_index do |k|
				if packages_name[k] == packages_conflict_name[i] && packages_arch[k] == packages_conflict_arch[i]
					j = k
				end
			end
			updated_conflicts_pkgs << [{name: packages_name[j], version: packages_version[j], architecture: packages_arch[j], description: packages_description[j]}, {name: packages_conflict_name[i], version: packages_conflict_version[i], architecture: packages_conflict_arch[i], description: packages_conflict_description[i]}]
			packages_name.delete_at(j)
			packages_version.delete_at(j)
			packages_arch.delete_at(j)
			packages_description.delete_at(j)
		end

		if updated_conflicts_pkgs.length > 0
			self.log_fetch "#{updated_conflicts_pkgs.length} package conflicts must be addressed...\n"
		end

		# create/update non-conflicting packages
		self.log_fetch "Processing packages...\n"
		packages_name.each_index do |i|
			pkg = Package.find_by repo_id: self.id, name: packages_name[i], architecture: Package.architectures[Package.arch_to_sym(packages_arch[i])]
			if pkg == nil
				# package doesn't already exist in repo
				p = Package.new({name: packages_name[i], version: packages_version[i], architecture: Package.arch_to_sym(packages_arch[i]), description: packages_description[i], repo_id: self.id})
				if !p.save
					raise "Unable to create new package! #{p.errors.messages}" 
				end

				num_new_pkgs += 1
			else
				# package exists in repo
				if pkg.version == packages_version[i] && pkg.description == packages_description[i]
					num_not_updated_pkgs += 1
				else
					pkg.attributes({name: packages_name[i], version: packages_version[i], architecture: Package.arch_to_sym(packages_arch[i]), description: packages_description[i], repo_id: self.id})
					if !pkg.save
						raise "Unable to update package! #{pkg.errors.messages}"
					end
					num_updated_pkgs += 1
				end
			end
		end
		self.log_fetch "#{num_new_pkgs} new packages, #{num_updated_pkgs} updated packages, and #{num_not_updated_pkgs} not updated...\n"

		# compare existing packages with updated package list to find removed packages
		self.log_fetch "Determining which packages were removed...\n"
		removed_packages = Package.select("name").map{|p| p.name} - packages_name

		removed_packages.each_index do |i|
			removed_pkgs << Package.find_by(name: removed_packages[i]).id
		end

		if removed_pkgs.length > 0
			self.log_fetch "#{removed_pkgs.length} removed packages must be addressed...\n"
		end

		# update fetch info
		self.fetch_info = {new: num_new_pkgs, updated: num_updated_pkgs, updated_conflicts: updated_conflicts_pkgs, not_updated: num_not_updated_pkgs, removed: removed_pkgs}
		self.fetch_last_date = release[:date]
		self.fetch_last_version = release[:version]
		self.save

		end_time = Time.now
		self.log_fetch "\n"
		self.log_fetch "[Done] Fetched package lists in #{((end_time - start_time) * 100).ceil / 100.0} sec"

		return true
	end
end