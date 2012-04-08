class AddFeaturedToSongAlbums < ActiveRecord::Migration
  def change
    add_column :song_albums, :featured, :boolean, :default =>false
  end
end
