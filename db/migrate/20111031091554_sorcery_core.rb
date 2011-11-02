class SorceryCore < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email, :null => false  # if you use another field as a username, for example email, you can safely remove this field.
      t.string :fname, :null => false  
      t.string :lname, :null => false
      t.string :crypted_password, :default => nil
      t.string :salt, :default => nil
      t.boolean :account_type, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
