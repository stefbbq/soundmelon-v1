class CreateArtistUsers < ActiveRecord::Migration
  def change
    rename_column :band_users, :band_id, :artist_id
    rename_table :band_users, :artist_users
  end
end
