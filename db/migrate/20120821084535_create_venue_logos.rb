class CreateVenueLogos < ActiveRecord::Migration
  def change
    create_table :venue_logos do |t|
      t.integer :venue_id
      t.string :logo_file_name
      t.string :logo_content_type
      t.integer :logo_file_size
      t.datetime :logo_updated_at

      t.timestamps
    end
  end
end
