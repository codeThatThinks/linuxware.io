class AddUrlExampleToRepoTypes < ActiveRecord::Migration
  def change
  	add_column :repo_types, :example_url, :text
  end
end
