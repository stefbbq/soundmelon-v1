class CreateUserItemConnections < ActiveRecord::Migration
  def change
    create_table :user_item_connections do |t|
      t.string :useritem_type
      t.integer :useritem_id
      t.string :connected_useritem_type
      t.integer :connected_useritem_id
      t.boolean :is_approved, :default =>false

      t.timestamps
    end
  end
end
