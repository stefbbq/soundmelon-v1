class User < ActiveRecord::Base
  has_many :user_posts
  has_one :band_user
  has_one :additional_info
  has_one :payment_info
  has_many :band_invitations
  attr_accessor :email_confirmation, :password_confirmation
  attr_accessible :email, :fname, :lname, :email_confirmation, :password, :password_confirmation
  validates :email, :presence => true
  validates :fname, :presence => true
  validates :lname, :presence => true
  validates :password, :presence => true, :on => :create 
  validates :password, :confirmation => true      
  validates :email, :uniqueness => true
  validates :email, :confirmation => true
  authenticates_with_sorcery!
  
  HUMANIZED_ATTRIBUTES = {
                           :fname => 'First Name',
                           :lname => 'Last Name'
                         }

  def self.human_attribute_name(attr,options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end 
end
