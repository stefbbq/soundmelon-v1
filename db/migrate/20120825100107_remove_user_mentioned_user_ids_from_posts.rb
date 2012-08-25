class RemoveUserMentionedUserIdsFromPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :mentioned_users
    remove_column :posts, :mentioned_user_ids
    remove_column :posts, :mentioned_artists
    remove_column :posts, :mentioned_artist_ids
    add_column :posts, :mention_post_ids, :string
  end

end
