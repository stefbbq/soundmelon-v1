class AddCaptionToBandPhotos < ActiveRecord::Migration
  def change
    add_column :band_photos, :caption, :string
  end
end
