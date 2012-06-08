class AddIsNewsFeedToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :is_newsfeed, :boolean, :default =>false
  end
end
