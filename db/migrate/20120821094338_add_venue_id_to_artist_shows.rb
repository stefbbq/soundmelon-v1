class AddVenueIdToArtistShows < ActiveRecord::Migration
  def change
    add_column :artist_shows, :venue_id, :integer
    rename_column :artist_shows, :venue, :venue_name
  end
end
