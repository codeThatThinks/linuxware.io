class Repo < ActiveRecord::Base
	validates :name, presence: true, uniqueness: true
	validates :type, presence: true
	validates :url, presence: true, uniqueness: true
	validates :distro, presence: true
	belongs_to :distro
	has_many :packages, dependent: :destroy
	serialize :fetch_info, Hash

	# fetch metadata cols:
	# => last_fetch, DateTime, date when fetch method was last run
	# => fetch_last_version, Float, version of release file from last fetch
	# => fetch_last_date, DateTime, date of release file from last fetch
	# => is_fetching, Boolean, is the fetch method currently running
	# => fetch_log, String, log from the last fetch

	def self.types
		[
			"DebianRepo",
			"DebianSourceRepo"
		]
	end

	def clear_fetch_log
		self.fetch_log = ""
		self.save
	end

	def log_fetch(msg)
		self.fetch_log << msg
		print msg
		self.save
	end

	def fetch
		raise 'Abstract method'
	end
end
