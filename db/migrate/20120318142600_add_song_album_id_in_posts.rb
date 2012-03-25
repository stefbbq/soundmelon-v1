class AddSongAlbumIdInPosts < ActiveRecord::Migration
  def change
    add_column :posts, :song_album_id, :integer, :default => nil
    add_column :posts, :song_id, :integer, :default => nil
  end
end
