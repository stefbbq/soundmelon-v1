class CreateVenueUsers < ActiveRecord::Migration
  def change
    create_table :venue_users do |t|
      t.integer :user_id
      t.integer :venue_id
      t.integer :access_level
      t.boolean :notification_on, :default =>true
      t.boolean :is_suspended, :default =>false

      t.timestamps
    end
  end
end
