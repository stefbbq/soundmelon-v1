class AddIsProcessedAndMetadataToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :is_processed, :boolean, :default =>false
    add_column :songs, :file_name,    :string # file's base name for different types of audio files
    add_column :songs, :title,        :string
    add_column :songs, :album,        :string
    add_column :songs, :artist,       :string
    add_column :songs, :genre,        :string
    add_column :songs, :track,        :string
    add_column :songs, :year,         :date    
  end
end
