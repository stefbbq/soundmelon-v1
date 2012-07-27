class ChangePostItems < ActiveRecord::Migration
  def change
    rename_column :posts, :band_id, :artist_id
    rename_column :posts, :mentioned_bands, :mentioned_artists
    rename_column :posts, :mentioned_band_ids, :mentioned_artist_ids
    rename_column :mentioned_posts, :band_id, :artist_id    
  end
end
