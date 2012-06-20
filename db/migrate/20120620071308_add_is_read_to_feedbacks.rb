class AddIsReadToFeedbacks < ActiveRecord::Migration
  def change
    add_column :feedbacks, :is_read, :boolean, :default =>false
    remove_column :feedbacks, :is_solved
  end
end
