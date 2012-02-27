class Band < ActiveRecord::Base
  before_validation :sanitize_mention_name
  
  acts_as_messageable :required => :body, :order => "created_at desc" 
  has_many :band_users, :dependent => :destroy
  has_many :band_members, :through => :band_users, :source => :user
  has_many :band_albums, :order => 'created_at desc'
  has_many :band_invitations, :dependent => :destroy
  has_many :song_albums, :order => 'created_at desc'
  has_many :posts
  has_many :mentioned_posts
  has_many :songs, :through => :song_albums
  

  acts_as_followable
  
  accepts_nested_attributes_for :band_invitations , :reject_if => proc { |attributes| attributes['email'].blank? }
  has_attached_file :logo, 
    :styles => { :small => '50x50#', :medium => '100x100>', :large => '350x180>' },
    :url => "/assets/images/bands/:id/:style/:basename.:extension"
  validates_attachment_content_type :logo, :content_type => ['image/jpeg', 'image/png', 'image/jpg'] 
  validates_attachment_size :logo, :less_than => 5.megabytes
  
  validates :name, :presence => true
  validates :name, :uniqueness => true
  validates :mention_name, :uniqueness => true

  searchable do
    text :genre
    text :name
  end
  
  def self.find_bands_in_mentioned_post mentioned_name_arr
    return where(:mention_name => mentioned_name_arr).select('DISTINCT(id)').all
  end
  
  def sanitize_mention_name
    unless self.mention_name.blank?
      self.mention_name = self.mention_name.strip =~ /^@/ ? self.mention_name : "@#{self.mention_name}"  
    end  
  end
  
  def find_own_as_well_as_mentioned_posts page=1   
    post_ids = []
    posts = Post.joins('LEFT OUTER JOIN mentioned_posts ON posts.id = mentioned_posts.post_id').where('mentioned_posts.band_id = :band_id or (posts.band_id = :band_id) and posts.is_deleted = :is_deleted and posts.is_bulletin = false',  :band_id => self.id, :is_deleted => false).order('posts.created_at DESC').uniq.paginate(:page => page, :per_page => POST_PER_PAGE).each{|post| post_ids << post.id}
    mark_mentioned_post_as_read post_ids
    mark_replies_post_as_read post_ids
    return posts
  end
  
  def find_own_posts page=1   
    Post.where('band_id = :band_id and is_deleted = :is_deleted',  :band_id => self.id, :is_deleted => false).order('created_at DESC').uniq.paginate(:page => page, :per_page => POST_PER_PAGE)
  end
  
  def is_part_of_post? post
    if(post.band == self || post.mentioned_posts.map{|mentioned_post| mentioned_post.band.id}.include?(self.id))
      return true
    else
      return false
    end
  end
  
  def mention_count
    self.mentioned_posts.where('band_id = ? and created_at >= ?', self.id, MENTION_COUNT_FOR_LAST_N_HOURS.hours.from_now).count
  end
  
  def song_albums_count
    self.song_albums.count
  end
  
  def songs_count
    self.songs.count
  end
  
  def bulletins page=1
    Post.where(:band_id => self.id, :is_bulletin => true, :is_deleted => false).order('created_at desc').paginate(:page => page, :per_page => POST_PER_PAGE)
  end
  
  def inbox page=1
    self.received_messages.paginate(:page => page, :per_page => MESSAGES_PER_PAGE)
  end
  
  def mentioned_in_posts page=1
    post_ids = []
    posts = Post.joins(:mentioned_posts).where('mentioned_posts.band_id = ?',  self.id).order('posts.created_at DESC').uniq.paginate(:page => page, :per_page => POST_PER_PAGE).each{|post| post_ids << post.id}
    mark_mentioned_post_as_read post_ids
    return posts
  end
  
  def unread_mentioned_post_count
    MentionedPost.where(:band_id => self.id, :status => UNREAD).count
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
    parent_posts = Post.where(:id => ancestry_post_ids, :band_id => self.id).map{|post| post.id}
    post_ids=[]
    posts = Post.where(:id => replies_post_ids, :ancestry => parent_posts).order('created_at desc').paginate(:page => page, :per_page => POST_PER_PAGE).each{|post| post_ids << post.id}
    mark_replies_post_as_read post_ids
    return posts
  end
  
  def limited_band_albums(n=3)
    self.band_albums.limit(n)
  end
  
  def limited_song_albums(n=3)
    self.song_albums.limit(n)
  end
  
  def limited_band_members(n=4)
     self.band_members.limit(n)
  end
  
  def limited_band_follower(n=4)
    self.user_followers.order('created_at desc').limit(n)
  end
  protected
  def mark_mentioned_post_as_read post_ids
     MentionedPost.where(:post_id => post_ids, :band_id => self.id).update_all(:status => READ)
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
    parent_posts = Post.where(:id => ancestry_post_ids, :band_id => self.id).map{|post| post.id}
    Post.where(:id => replies_post_ids, :ancestry => parent_posts, :is_read => UNREAD)
    #Post.joins('INNER JOIN posts as c').where('posts.id = c.ancestry and c.ancestry is not null and c.is_read = ? and posts.user_id = ?', UNREAD, self.id)
  end
  
  
end