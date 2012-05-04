class CreateTourPosts < ActiveRecord::Migration
  def change
    create_table :tour_posts do |t|
      t.integer :user_id, :null =>false
      t.integer :tour_id, :null =>false
      t.string :msg,      :null =>false
      t.integer :band_id      
      t.string :ancestry
      t.boolean :is_bulletin
      t.boolean :is_deleted
      t.boolean :is_read

      t.timestamps
    end
  end
end
