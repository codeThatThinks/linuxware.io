class Software < ActiveRecord::Base
	has_many :packages
	validates :name, presence: true, uniqueness: true
	searchkick text_start: [:name]
end
