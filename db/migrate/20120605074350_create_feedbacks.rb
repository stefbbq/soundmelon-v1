class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.integer :feedback_topic_id,     :null =>false
      t.string :name
      t.string :email
      t.string :user_type
      t.integer :user_id
      t.text :content             
      t.boolean :is_solved,             :default =>false

      t.timestamps
    end
  end
end
