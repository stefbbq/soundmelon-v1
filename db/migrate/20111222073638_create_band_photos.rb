class CreateBandPhotos < ActiveRecord::Migration
  def change
    create_table :band_photos do |t|
      t.references :band_album
      t.references :user
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.timestamps
    end
  end
end
