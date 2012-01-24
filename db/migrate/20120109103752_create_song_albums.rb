class CreateSongAlbums < ActiveRecord::Migration
  def change
    create_table :song_albums do |t|
      t.references :band
      t.references :user
      t.string :album_name
      t.string :cover_img_file_name
      t.string :cover_img_content_type
      t.integer :cover_img_file_size
      t.datetime :cover_img_updated_at
      t.text :description
      t.timestamps
    end
  end
end
