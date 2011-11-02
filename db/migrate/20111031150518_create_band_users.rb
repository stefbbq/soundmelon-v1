class CreateBandUsers < ActiveRecord::Migration
  def change
    create_table :band_users do |t|
      t.integer :user_id, :null => false
      t.integer :band_id
      t.integer :access_level
      t.boolean :is_deleted, :default => 0
      t.timestamps
    end
  end
end
