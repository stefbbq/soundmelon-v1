class CreateBandInvitations < ActiveRecord::Migration
  def change
    create_table :band_invitations do |t|
      t.integer   :band_id
      t.integer   :user_id
      t.string    :email
      t.string    :token
      t.boolean   :access_level, :default => 0
      t.timestamps
    end
  end
end
