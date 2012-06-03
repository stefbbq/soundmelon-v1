class CreateBandLogos < ActiveRecord::Migration

  def change
    create_table :band_logos do |t|
      t.integer :band_id, :null => false
      t.timestamps
    end
  end
end
