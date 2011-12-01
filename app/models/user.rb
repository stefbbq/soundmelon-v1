class User < ActiveRecord::Base
  acts_as_messageable :required => :body ,:order => "created_at desc" 
  acts_as_followable
  acts_as_follower

  has_many :user_posts, :order => "created_at desc"
  has_one :band_user
  has_one :additional_info
  has_one :payment_info
  has_many :band_invitations
  has_many :albums
  has_one :profile_pic
  
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

  def get_full_name
    "#{self.fname} #{self.lname}"
  end
  
end
