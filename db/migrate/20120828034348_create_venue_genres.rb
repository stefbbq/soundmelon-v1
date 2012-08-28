class CreateVenueGenres < ActiveRecord::Migration
  def change
    create_table :genres_venues, :id =>false do |t|
      t.integer :venue_id,  :null =>false
      t.integer :genre_id,  :null =>false
    end
  end
end
