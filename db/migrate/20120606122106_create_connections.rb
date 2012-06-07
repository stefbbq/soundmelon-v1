class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.integer :band_id
      t.integer :connected_band_id
      t.boolean :is_approved, :default =>false

      t.timestamps
    end
  end
end
