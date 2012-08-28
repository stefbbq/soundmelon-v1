class CreateUsersGenres < ActiveRecord::Migration
  def change
    create_table :genres_users, :id =>false do |t|
      t.integer :user_id,  :null =>false
      t.integer :genre_id,  :null =>false
    end
  end
end
