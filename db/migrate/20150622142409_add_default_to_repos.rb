class AddDefaultToRepos < ActiveRecord::Migration
  def change
  	change_column_default :repos, :is_fetching, false
  end
end
