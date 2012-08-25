class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string :name
      t.string :mention_name
      t.text :info
      t.date :est_date
      t.string :country
      t.string :state
      t.string :city
      t.string :address
      t.integer :latitude
      t.integer :longitude
      t.string :mapped_address
      t.integer :profile_completeness
      t.string :facebook_page
      t.string :twitter_page
      t.boolean :is_private, :default =>false

      t.timestamps
    end
  end
end
