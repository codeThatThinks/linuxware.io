class AddSoftwareToPackages < ActiveRecord::Migration
  def change
  	add_column :packages, :software_id, :integer
  end
end
