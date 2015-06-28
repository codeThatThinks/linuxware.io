class AddDefaultTagsToSoftware < ActiveRecord::Migration
  def change
  	change_column_default :softwares, :tags, ""
  end
end
