class CreateRepoTypes < ActiveRecord::Migration
  def change
    create_table :repo_types do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
