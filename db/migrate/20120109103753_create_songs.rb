class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.references :user
      t.references :song_album
      t.text :description
      t.string :song_file_name
      t.string :song_content_type
      t.integer :song_file_size
      t.datetime :song_updated_at
      t.integer :total_played, :default => 0
      t.timestamps
    end
  end
end
