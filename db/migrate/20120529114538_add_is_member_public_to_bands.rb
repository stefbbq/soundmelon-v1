class AddIsMemberPublicToBands < ActiveRecord::Migration
  def change
    add_column :bands, :is_member_public, :boolean, :default =>true
  end
end
