class AddEstDateToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :est_date, :date
  end
end
