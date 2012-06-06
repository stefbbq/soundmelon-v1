class AddSubjectToFeedbacks < ActiveRecord::Migration
  def change
    add_column :feedbacks, :subject, :string
    remove_column :feedbacks, :name
    remove_column :feedbacks, :email
  end
end
