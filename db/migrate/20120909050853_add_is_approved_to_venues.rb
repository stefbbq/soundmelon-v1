class AddIsApprovedToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :approved, :boolean, :default =>true
  end
end
