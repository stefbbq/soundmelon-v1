class CreateAdditionalInfos < ActiveRecord::Migration
  def change
    create_table :additional_infos do |t|
      t.integer :user_id, :null => false
      t.boolean :gender, :default => 1
      t.integer :age
      t.string :location
      t.string :favourite_genre
      t.timestamps
    end
  end
end
