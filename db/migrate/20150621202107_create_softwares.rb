class CreateSoftwares < ActiveRecord::Migration
  def change
    create_table :softwares do |t|
      t.string :name
      t.text :description
      t.string :url
      t.string :license

      t.timestamps null: false
    end
  end
end
