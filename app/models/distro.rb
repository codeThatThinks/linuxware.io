class Distro < ActiveRecord::Base
	validates :name, presence: true, uniqueness: true
	has_many :repos, dependent: :destroy
end
