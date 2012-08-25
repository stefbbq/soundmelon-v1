class RemoveUserArtistIdFromMentionedPosts < ActiveRecord::Migration
  def change
    remove_column :mentioned_posts, :user_id
    remove_column :mentioned_posts, :artist_id
  end
end
