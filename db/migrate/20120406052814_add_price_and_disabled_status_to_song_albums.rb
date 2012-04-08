class AddPriceAndDisabledStatusToSongAlbums < ActiveRecord::Migration
  def change
    add_column :song_albums, :price, :float, :default =>0.0
    add_column :song_albums, :disabled, :boolean, :default =>0
  end
end
