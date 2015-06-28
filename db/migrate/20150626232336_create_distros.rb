class CreateDistros < ActiveRecord::Migration
  def change
    create_table :distros do |t|
    	t.string :name
    end
  end
end
