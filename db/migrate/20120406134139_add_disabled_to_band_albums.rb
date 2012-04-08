class AddDisabledToBandAlbums < ActiveRecord::Migration
  def change
    add_column :band_albums, :disabled, :boolean, :default =>false
  end
end
