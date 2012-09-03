class CreateArtistInfluencers < ActiveRecord::Migration
  def change
    create_table :artist_influencers do |t|
      t.string :name
      t.integer :artist_id
      t.integer :artist_item_id

      t.timestamps
    end
  end
end
