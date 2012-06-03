class AddCoverImageIdToBandAlbums < ActiveRecord::Migration
  def change
    add_column    :band_albums, :cover_image_id, :integer
    remove_column :band_photos, :is_cover_image
  end
end
