class AddLastVersionAndLastDateToRepos < ActiveRecord::Migration
  def change
  	add_column :repos, :fetch_last_version, :float
  	add_column :repos, :fetch_last_date, :datetime
  end
end
