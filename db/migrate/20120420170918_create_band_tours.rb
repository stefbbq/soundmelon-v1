class CreateBandTours < ActiveRecord::Migration
  def change
    create_table :band_tours do |t|
      t.integer :band_id, :null =>false
      t.date :tour_date,  :null =>false
      t.string :venue,    :null =>false
      t.string :country,  :null =>false
      t.string :ticket
      t.string :ticket_status
      t.string :web_page
      t.string :web_page1
      t.string :web_page2
      t.text :more_info

      t.timestamps
    end
  end
end
