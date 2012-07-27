class CreateArtistMusics < ActiveRecord::Migration
  def change
    rename_column :song_albums, :band_id, :artist_id
    rename_table :song_albums, :artist_musics
    rename_column :songs, :song_album_id, :artist_music_id
  end
end
