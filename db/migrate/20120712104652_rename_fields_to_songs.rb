class RenameFieldsToSongs < ActiveRecord::Migration
  def change
    rename_column :songs, :artist, :artist_name
    rename_column :songs, :album, :album_name
  end
end
