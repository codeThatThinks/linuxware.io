class AddArchToPackages < ActiveRecord::Migration
  def change
  	add_column :packages, :architecture, :integer
  end
end
