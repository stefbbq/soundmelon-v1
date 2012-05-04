class CreateGenreUsers < ActiveRecord::Migration
  def change
    create_table :genre_users do |t|
      t.integer :user_id
      t.integer :genre_id
      t.integer :liking_count, :default =>1

      t.timestamps
    end
  end
end
