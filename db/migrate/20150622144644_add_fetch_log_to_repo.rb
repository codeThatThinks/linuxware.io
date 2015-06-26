class AddFetchLogToRepo < ActiveRecord::Migration
  def change
  	add_column :repos, :fetch_log, :text
  end
end
