class AddIsCoverImageToBandPhotos < ActiveRecord::Migration
  def change
    add_column :band_photos, :is_cover_image, :boolean, :default =>false
  end
end
