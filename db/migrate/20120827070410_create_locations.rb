class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :item_type
      t.integer :item_id
      t.string :name
      t.string :fmt_name
      t.string :country
      t.string :lat
      t.string :lng
      t.string :url
      t.boolean :is_valid, :default =>false

      t.timestamps
    end
  end
end
