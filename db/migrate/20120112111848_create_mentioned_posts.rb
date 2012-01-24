class CreateMentionedPosts < ActiveRecord::Migration
  def change
    create_table :mentioned_posts do |t|
      t.references :post
      t.references :user
      t.references :band
      t.integer :status
      t.timestamps
    end
  end
end
