class AddShortDescToSoftware < ActiveRecord::Migration
  def change
  	add_column :softwares, :short_description, :text
  end
end
