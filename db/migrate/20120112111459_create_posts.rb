class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :user
      t.references :artist
      t.string :msg
      t.integer :parent_id
      t.timestamps
    end
  end
end
