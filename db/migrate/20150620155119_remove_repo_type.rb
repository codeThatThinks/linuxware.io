class RemoveRepoType < ActiveRecord::Migration
  def change
  	drop_table(:repo_types)
  end
end
