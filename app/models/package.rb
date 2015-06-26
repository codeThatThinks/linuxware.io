class Package < ActiveRecord::Base
	belongs_to :repo
	belongs_to :software
	validates :name, presence: true
	validates :version, presence: true
	validates :architecture, presence: true
	validates :repo_id, presence: true
	validates_uniqueness_of :name, scope: [:architecture, :repo], message: "conflicts with an existing package"

	enum architecture: [:any, :IA_32, :x86_64]

	def self.arch_whitelist
		[
			"all",
			"i386",
			"i486",
			"i586",
			"i686",
			"i786",
			"amd64",
			"x86_64"
		]
	end

	def self.arch_to_sym(arch_string)
		case arch_string
			when "all" then :any
			when "any" then :any
			when "i386" then :IA_32
			when "i486" then :IA_32
			when "i586" then :IA_32
			when "i686" then :IA_32
			when "i768" then :IA_32
			when "amd64" then :x86_64
			when "x86_64" then :x86_64
			else false
		end
	end
end