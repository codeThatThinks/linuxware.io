class AddTypeToRepoType < ActiveRecord::Migration
  def change
  	add_column :repo_types, :type, :string
  end
end
