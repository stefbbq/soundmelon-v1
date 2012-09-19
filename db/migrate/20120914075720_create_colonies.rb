class CreateColonies < ActiveRecord::Migration
  def change
    create_table :colonies do |t|
      t.string :name
      t.text :bio
      t.string :colony_type
      t.boolean :hidden, :default =>false
      t.string :country
      t.string :state
      t.string :city
      t.string :address
      t.string :location_city
      t.string :age_group
      t.string :genres
      t.string :tags

      t.timestamps
    end
  end
end
