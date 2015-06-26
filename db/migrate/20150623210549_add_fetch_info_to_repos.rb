class AddFetchInfoToRepos < ActiveRecord::Migration
  def change
  	add_column :repos, :fetch_info, :text
  end
end
