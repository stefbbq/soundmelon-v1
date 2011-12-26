class User < ActiveRecord::Base
  acts_as_messageable :required => :body ,:order => "created_at desc" 
  acts_as_followable
  acts_as_follower
  
  validates :email, :presence => true
  validates :fname, :presence => true
  validates :lname, :presence => true
  
  has_many :user_posts, :order => "created_at desc"
  #has_one :band_user
  has_many :band_users
  has_many :bands, :through => :band_users
  has_one :additional_info
  has_one :payment_info
  has_many :band_invitations
  has_many :albums
  has_one :profile_pic
  has_many :band_albums
  has_many :band_photos
  
  attr_accessor :email_confirmation, :password_confirmation
  attr_accessible :email, :fname, :lname, :email_confirmation, :password, :password_confirmation
  
  validates :password, :presence => true, :on => :create 
  validates :password, :confirmation => true      
  validates :email, :uniqueness => true
  validates :email, :confirmation => true
  authenticates_with_sorcery! 
  
  searchable do
    text :fname
    text :lname
    string :activation_state
  end
  
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
  
  def is_admin_of_band?(band) 
    admin_band_members_id_arr = band.band_members.where('band_users.access_level = 1').map{|band_member| band_member.id}
    if admin_band_members_id_arr.include?(self.id)
      return true
    else
       return false
    end
  end
  
  def is_member_of_band?(band)
    band_members_id_arr = band.band_members.map{|band_member| band_member.id}
    band_members_id_arr.include?(self.id) ? true : false
  end
  
  #return all the bands in which the user is admin except the band that comes as argument
  def admin_bands_except(band)
    self.bands.where('bands.id != ?',band.id)
  end
end
