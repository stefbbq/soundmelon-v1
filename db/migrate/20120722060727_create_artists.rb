class CreateArtists < ActiveRecord::Migration
  def change
    rename_column :bands, :band_logo_url, :artist_logo_url
    rename_table :bands, :artists
  end
end
