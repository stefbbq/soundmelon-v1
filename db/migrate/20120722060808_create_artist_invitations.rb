class CreateArtistInvitations < ActiveRecord::Migration
  def change
    rename_column :band_invitations, :band_id, :artist_id
    rename_table :band_invitations, :artist_invitations
  end
end
