class CreateArtistShows < ActiveRecord::Migration
  # just changing the existing table
  def change
    remove_column :band_tours, :country
    remove_column :band_tours, :web_page
    remove_column :band_tours, :web_page1
    remove_column :band_tours, :web_page2
    remove_column :band_tours, :ticket
    remove_column :band_tours, :ticket_status    
    rename_column :band_tours, :band_id, :artist_id
    rename_column :band_tours, :tour_date, :show_date
    add_column :band_tours, :city, :string
    rename_table :band_tours, :artist_shows
  end
end
