class RemovePhotosPostsAndTourPosts < ActiveRecord::Migration
  def up
    drop_table :photo_posts
    drop_table :tour_posts
  end

  def down    
  end
end
