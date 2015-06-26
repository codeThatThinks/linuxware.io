class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :name
      t.string :version
      t.belongs_to :repo, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
