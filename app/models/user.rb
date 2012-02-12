class User < ActiveRecord::Base
  before_validation :sanitize_mention_name
  
  acts_as_messageable :required => :body ,:order => "created_at desc" 
  acts_as_followable
  acts_as_follower
  
  validates :email, :presence => true
  validates :fname, :presence => true
  validates :lname, :presence => true
  validates :mention_name, :uniqueness => true
  
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
  has_many :songs
  has_many :song_albums
  has_many :posts
  has_many :mention_posts
  
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
  
  def self.find_users_in_mentioned_post mentioned_name_arr
    return where(:mention_name => mentioned_name_arr).select('DISTINCT(id)').all
  end

  def sanitize_mention_name
    unless self.mention_name.blank?
      self.mention_name = self.mention_name.strip =~ /^@/ ? self.mention_name : "@#{self.mention_name}"  
    end  
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
  
  def find_own_as_well_as_mentioned_posts page=1   
    Post.joins('LEFT OUTER JOIN mentioned_posts ON posts.id = mentioned_posts.post_id').where('mentioned_posts.user_id = :current_user_id or (posts.user_id = :current_user_id and posts.is_deleted = :is_deleted)',  :current_user_id => self.id, :is_deleted => false).order('posts.created_at DESC').uniq.paginate(:page => page, :per_page => 10)
  end
  
  def find_own_as_well_as_following_user_posts page=1
    user_as_well_as_following_users_id = [self.id]
    self.following_users.map{|follow|  user_as_well_as_following_users_id << follow.id}
    user_following_band_ids = []
    self.following_bands.map{|band|  user_following_band_ids << band.id}
    Post.joins('LEFT OUTER JOIN mentioned_posts ON posts.id = mentioned_posts.post_id').where('mentioned_posts.user_id = :current_user_id or (posts.user_id in (:current_user_as_well_as_following_users_id) or posts.band_id in (:user_following_band_ids))  and posts.is_deleted = :is_deleted and is_bulletin = false', :current_user_id => self.id, :current_user_as_well_as_following_users_id =>  user_as_well_as_following_users_id, :user_following_band_ids => user_following_band_ids, :is_deleted => false).order('posts.created_at DESC').uniq.paginate(:page => page, :per_page => 10)
  end
  
  def is_part_of_post? post
    if(post.user == self || post.mentioned_posts.map{|mentioned_post| mentioned_post.user.id}.include?(self.id))
      return true
    else
      return false
    end
  end
  
  def mentioned_posts page=1
    Post.joins(:mentioned_posts).where('mentioned_posts.user_id = ?',  self.id).order('posts.created_at DESC').uniq.paginate(:page => page, :per_page => 10)
  end
end
