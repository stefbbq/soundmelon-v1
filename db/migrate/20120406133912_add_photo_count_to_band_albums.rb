class AddPhotoCountToBandAlbums < ActiveRecord::Migration
  def change
    add_column :band_albums, :photo_count, :integer, :default =>0
  end
end
