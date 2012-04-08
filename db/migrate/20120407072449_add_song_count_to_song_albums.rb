class AddSongCountToSongAlbums < ActiveRecord::Migration
  def change
    add_column :song_albums, :song_count, :integer, :default =>0
  end
end
