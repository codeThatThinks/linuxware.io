class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string :name
      t.text :description
      t.belongs_to :distro, index: true, foreign_key: true
    end
  end
end
