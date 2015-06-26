class RemoveDescriptionFromRepos < ActiveRecord::Migration
  def change
  	remove_column :repos, :description
  end
end
