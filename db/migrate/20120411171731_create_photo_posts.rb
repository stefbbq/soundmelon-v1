class CreatePhotoPosts < ActiveRecord::Migration
  def change
    create_table :photo_posts do |t|
      t.references :user
      t.references :band
      t.string :msg      
      t.string :ancestry
      t.boolean :is_bulletin, :default =>false
      t.boolean :is_deleted, :default =>false
      t.boolean :is_read, :default =>false
      t.integer :band_album_id
      t.integer :band_photo_id
      t.timestamps
    end
  end
end
