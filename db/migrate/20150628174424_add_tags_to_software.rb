class AddTagsToSoftware < ActiveRecord::Migration
  def change
  	add_column :softwares, :tags, :text
  end
end
