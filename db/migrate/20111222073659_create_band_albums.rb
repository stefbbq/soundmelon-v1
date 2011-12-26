class CreateBandAlbums < ActiveRecord::Migration
  def change
    create_table :band_albums do |t|
      t.references :band
      t.references :user
      t.string :name
      t.timestamps
    end
  end
end
