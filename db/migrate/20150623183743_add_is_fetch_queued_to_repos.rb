class AddIsFetchQueuedToRepos < ActiveRecord::Migration
  def change
  	add_column :repos, :is_fetch_queued, :boolean
  end
end
