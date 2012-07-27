class CreateArtistPhotos < ActiveRecord::Migration
  def change
    rename_column :band_photos, :band_album_id, :artist_album_id
    rename_table :band_photos, :artist_photos
  end
end
