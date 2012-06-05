class CreateFeedbackTopics < ActiveRecord::Migration
  def change
    create_table :feedback_topics do |t|
      t.string :name
      t.string :info
      t.string :emails

      t.timestamps
    end    
  end
end
