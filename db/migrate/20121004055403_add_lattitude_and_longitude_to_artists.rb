class AddLattitudeAndLongitudeToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :address, :string
    add_column :artists, :longitude, :float
    add_column :artists, :latitude, :float
  end
end
