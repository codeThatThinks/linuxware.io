class AddRepoTypoToRepos < ActiveRecord::Migration
  def change
  	add_belongs_to :repos, :repo_type, index: true
  end
end
