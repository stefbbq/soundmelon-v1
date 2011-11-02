class CreatePaymentInfos < ActiveRecord::Migration
  def change
    create_table :payment_infos do |t|
      t.integer :user_id, :null => false
      t.string :card_type
      t.string :name_on_card
      t.string :expire_month
      t.string :expire_year
      t.string :card_number
      t.string :security_code
      t.timestamps
    end
  end
end
