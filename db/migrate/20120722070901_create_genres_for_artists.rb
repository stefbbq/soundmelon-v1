class CreateGenresForArtists < ActiveRecord::Migration
  def change
    rename_column :bands_genres, :band_id, :artist_id
    rename_table :bands_genres, :artists_genres
    rename_column :connections, :band_id, :artist_id
    rename_column :connections, :connected_band_id, :connected_artist_id
  end
end
