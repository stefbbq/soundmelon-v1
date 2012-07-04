class AddNotificationOnToBandUsers < ActiveRecord::Migration
  def change
    add_column :band_users, :notification_on, :boolean, :default =>true
    add_column :users, :notification_on, :boolean, :default =>true
  end
end
