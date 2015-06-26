class RemoveRepoTypeIdFromRepos < ActiveRecord::Migration
  def change
  	remove_column :repos, :repo_type_id
  end
end
