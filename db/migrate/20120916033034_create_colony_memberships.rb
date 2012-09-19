class CreateColonyMemberships < ActiveRecord::Migration
  def change
    create_table :colony_memberships do |t|
      t.integer :colony_id
      t.string :member_type
      t.integer :member_id
      t.boolean :is_admin, :default =>false
      t.boolean :suspended, :default =>false
      t.boolean :approved, :default =>false

      t.timestamps
    end
  end
end
