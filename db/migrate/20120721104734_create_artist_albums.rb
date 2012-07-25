class CreateArtistAlbums < ActiveRecord::Migration
  def change
    rename_column :band_albums, :band_id, :artist_id
    rename_table :band_albums, :artist_albums
  end
end
