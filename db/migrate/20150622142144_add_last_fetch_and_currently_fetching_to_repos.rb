class AddLastFetchAndCurrentlyFetchingToRepos < ActiveRecord::Migration
  def change
  	add_column :repos, :last_fetch, :datetime
  	add_column :repos, :is_fetching, :boolean
  end
end
