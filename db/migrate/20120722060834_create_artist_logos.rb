class CreateArtistLogos < ActiveRecord::Migration
  def change
    rename_column :band_logos, :band_id, :artist_id
    rename_table :band_logos, :artist_logos
  end
end
