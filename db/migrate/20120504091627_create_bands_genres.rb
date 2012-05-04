class CreateBandsGenres < ActiveRecord::Migration
  def change
    create_table :bands_genres, :id =>false do |t|
      t.integer :band_id,   :null =>false
      t.integer :genre_id,  :null =>false      
    end
  end
end
