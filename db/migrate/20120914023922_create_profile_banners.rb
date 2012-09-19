class CreateProfileBanners < ActiveRecord::Migration
  def change
    create_table :profile_banners do |t|
      t.integer :profileitem_id
      t.string :profileitem_type            
      t.string  :image_file_name
      t.string  :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.boolean :is_current, :default =>true
      t.timestamps
    end
  end
end
