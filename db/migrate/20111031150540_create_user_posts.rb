class CreateUserPosts < ActiveRecord::Migration
  def change
    create_table :user_posts do |t|
      t.integer :user_id, :null => false
      t.string :post
      t.boolean :is_deleted, :default => 0
      t.timestamps
    end
  end
end
