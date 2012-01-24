class AddBandMentionNameToBand < ActiveRecord::Migration
  def change
    add_column :bands, :mention_name, :string
  end
end
