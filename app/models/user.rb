class User < ActiveRecord::Base
  authenticates_with_sorcery!
  
  
  acts_as_messageable :required => :body #,:order => "created_at desc" 
  acts_as_followable
  acts_as_follower
  
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
  has_many :playlists
  
  attr_accessor :email_confirmation, :password_confirmation
  attr_accessible :email, :fname, :lname, :email_confirmation, :password, :password_confirmation, :tac, :mention_name
  
  validates :email, :presence => true
  validates :fname, :presence => true
  validates :lname, :presence => true
  validates :mention_name, :uniqueness => true
  validates :password, :presence => true, :on => :create 
  validates :password, :confirmation => true      
  validates :email, :uniqueness => true
  validates :email, :confirmation => true
  validates :tac, :acceptance => true
  before_validation :sanitize_mention_name 
  
  searchable do
    text :fname
    text :lname
    string :activation_state
  end
  
  HUMANIZED_ATTRIBUTES = {
                           :fname => 'First Name',
                           :lname => 'Last Name',
                           :tac => 'Terms and Condition'
                         }

  def self.human_attribute_name(attr,options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end 
  
  def self.find_users_in_mentioned_post mentioned_name_arr
    return where(:mention_name => mentioned_name_arr).select('DISTINCT(id)').all
  end

  def sanitize_mention_name
    unless self.mention_name.blank?
      self.mention_name = "@#{self.mention_name.parameterize}"
      self.mention_name = nil if self.mention_name.size == 1
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
    Post.joins('LEFT OUTER JOIN mentioned_posts ON posts.id = mentioned_posts.post_id').where('mentioned_posts.user_id = :current_user_id or (posts.user_id = :current_user_id and posts.is_deleted = :is_deleted)',  :current_user_id => self.id, :is_deleted => false).order('posts.created_at DESC').uniq.paginate(:page => page, :per_page => POST_PER_PAGE)
  end
  
  def find_own_posts page=1   
    Post.where('posts.user_id = :current_user_id and posts.is_deleted = :is_deleted',  :current_user_id => self.id, :is_deleted => false).order('created_at DESC').uniq.paginate(:page => page, :per_page => POST_PER_PAGE)
  end
  
  def find_own_as_well_as_following_user_posts page=1
    user_as_well_as_following_users_id = [self.id]
    self.following_users.map{|follow|  user_as_well_as_following_users_id << follow.id}
    user_following_band_ids = []
    self.following_bands.map{|band|  user_following_band_ids << band.id}
    post_ids=[]
    posts = Post.joins('LEFT OUTER JOIN mentioned_posts ON posts.id = mentioned_posts.post_id').where('mentioned_posts.user_id = :current_user_id or (posts.user_id in (:current_user_as_well_as_following_users_id) or posts.band_id in (:user_following_band_ids))  and posts.is_deleted = :is_deleted and is_bulletin = false', :current_user_id => self.id, :current_user_as_well_as_following_users_id =>  user_as_well_as_following_users_id, :user_following_band_ids => user_following_band_ids, :is_deleted => false).order('posts.created_at DESC').uniq.paginate(:page => page, :per_page => POST_PER_PAGE).each{|post| post_ids << post.id}
    #mark_mentioned_post_as_read post_ids
    #mark_replies_post_as_read post_ids
    return posts
  end
  
  def is_part_of_post? post
    if(post.user == self || post.mentioned_posts.map{|mentioned_post| mentioned_post.user.id}.include?(self.id))
      return true
    else
      return false
    end
  end

  def inbox page=1
    self.received_messages.paginate(:page => page, :per_page => MESSAGES_PER_PAGE)
  end
  
  def mentioned_posts page=1
    post_ids = []
    posts = Post.joins(:mentioned_posts).where('mentioned_posts.user_id = ?',  self.id).order('posts.created_at DESC').uniq.paginate(:page => page, :per_page => POST_PER_PAGE).each{|post| post_ids << post.id}
    mark_mentioned_post_as_read post_ids
    return posts
  end
  
  def unread_mentioned_post_count
    MentionedPost.where(:user_id => self.id, :status => UNREAD).count
  end
    
  def unread_post_replies_count
    unread_post_replies.count
  end
  
  def replies_post page=1
    replies_post_ids = []
    ancestry_post_ids = []
    Post.where('ancestry is not null and is_deleted = ?', false).map do |post| 
      replies_post_ids << post.id
      ancestry_post_ids << post.ancestry
    end
    parent_posts = Post.where(:id => ancestry_post_ids, :user_id => self.id).map{|post| post.id}
    post_ids=[]
    posts = Post.where(:id => replies_post_ids, :ancestry => parent_posts).order('created_at desc').paginate(:page => page, :per_page => POST_PER_PAGE).each{|post| post_ids << post.id}
    mark_replies_post_as_read post_ids
    return posts
  end
  
  
  protected
  def mark_mentioned_post_as_read post_ids
     MentionedPost.where(:post_id => post_ids, :user_id => self.id).update_all(:status => READ)
  end
  
  def mark_replies_post_as_read post_ids
    unread_replies_post_ids = unread_post_replies.map{|post| post.id}
    post_need_to_be_marked_as_read = post_ids & unread_replies_post_ids
    Post.where(:id => post_need_to_be_marked_as_read).update_all(:is_read => READ)
  end
  
  def unread_post_replies
    replies_post_ids = []
    ancestry_post_ids = []
    Post.where('ancestry is not null and is_read = ? and is_deleted = ?', UNREAD, false).map do |post| 
      replies_post_ids << post.id
      ancestry_post_ids << post.ancestry
    end
    parent_posts = Post.where(:id => ancestry_post_ids, :user_id => self.id).map{|post| post.id}
    Post.where(:id => replies_post_ids, :ancestry => parent_posts, :is_read => UNREAD)
    #Post.joins('INNER JOIN posts as c').where('posts.id = c.ancestry and c.ancestry is not null and c.is_read = ? and posts.user_id = ?', UNREAD, self.id)
  end
  
end