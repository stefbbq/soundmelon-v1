class Band < ActiveRecord::Base
  
  acts_as_messageable
  acts_as_followable  

  has_many :band_users, :dependent => :destroy
  has_many :band_members, :through => :band_users, :source => :user
  has_many :band_albums, :order => 'created_at desc', :dependent =>:destroy
  has_many :band_tours, :order =>'created_at desc', :dependent =>:destroy
  has_many :band_invitations, :dependent => :destroy
  has_many :song_albums, :order => 'created_at desc', :dependent =>:destroy
  has_many :posts, :dependent => :destroy
  has_many :mentioned_posts
  has_many :songs, :through => :song_albums
  has_and_belongs_to_many :genres
  has_one :band_logo , :dependent =>:destroy
  attr_reader :genre_tokens

  has_many :connections, :dependent =>:destroy
  has_many :connected_bands, :through =>:connections, :source =>:connected_band, :conditions =>["is_approved = ?", true]


  accepts_nested_attributes_for :band_invitations , :reject_if => proc { |attributes| attributes['email'].blank? }
  
  validates :name, :presence => true
  validates :name, :uniqueness => true
  validates :mention_name, :presence => true
  validates :mention_name, :uniqueness => true

  before_validation :sanitize_mention_name  
  
  searchable do
    text :genres_name
    text :name
  end

  def genres_name
    genres_name_list = ''
    self.genres.map{|gen| genres_name_list += "#{gen.name},"}
    genres_name_list.chomp(',')
  end

  def genre_tokens=(ids)
    self.genre_ids = ids.split(",")
  end
  
  def self.find_bands_in_mentioned_post mentioned_name_arr
    return where(:mention_name => mentioned_name_arr).select('DISTINCT(id), mention_name').all
  end
  
  def sanitize_mention_name
    unless self.mention_name.blank?
      self.mention_name = "@#{self.mention_name.parameterize}"
      self.mention_name = nil if self.mention_name.size == 1
    end  
  end
  
  def find_own_as_well_as_mentioned_posts page=1   
    post_ids = []
    posts = Post.joins('LEFT OUTER JOIN mentioned_posts ON posts.id = mentioned_posts.post_id').where('mentioned_posts.band_id = :band_id or (posts.band_id = :band_id) and posts.is_deleted = :is_deleted and posts.is_bulletin = false',  :band_id => self.id, :is_deleted => false).order('posts.created_at DESC').uniq.paginate(:page => page, :per_page => POST_PER_PAGE).each{|post| post_ids << post.id}
    #mark_mentioned_post_as_read post_ids
    #mark_replies_post_as_read post_ids
    return posts
  end
  
  def find_own_posts page=1   
    Post.where('band_id = :band_id and is_deleted = :is_deleted and is_bulletin = :is_bulletin',  :band_id => self.id, :is_deleted => false, :is_bulletin =>false).order('created_at DESC').uniq.paginate(:page => page, :per_page => POST_PER_PAGE)
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
  
  def limited_band_albums(n=BAND_PHOTO_ALBUM_SHOW_LIMIT)
    self.band_albums.limit(n)
  end
  
  def limited_song_albums(n=BAND_SONG_ALBUM_SHOW_LIMIT)
    self.song_albums.limit(n)
  end
  
  def limited_band_members(n=BAND_MEMBER_SHOW_LIMIT)
    self.band_members.limit(n)
  end 

  def limited_band_tours(n=TOUR_DATE_SHOW_LIMIT)
    self.band_tours.order('created_at desc').limit(n)
  end

  def limited_band_featured_songs(n=ARTIST_FEATURED_SONG_LIMIT)
    self.songs.featured.order('rand()').limit(n)
  end

  def self.find_band condition_params
    Band.where(:name => condition_params[:band_name]).first
  end

  def self.find_band_and_members condition_params
    Band.where(:name => condition_params[:band_name]).includes(:band_members).first
  end
  
  def followers page = 1
    follows   = Follow.where("followable_id = ? and followable_type = ?", self.id, self.class.name).page(page).per(FOLLOWING_FOLLOWER_PER_PAGE)
    followers = follows.map{|follow| follow.follower}
    followers
  end

  def limited_followers
    follows   = Follow.where("followable_id = ? and followable_type = ?", self.id, self.class.name).order('RAND()').limit(NO_OF_FOLLOWER_TO_DISPLAY)
    followers = follows.map{|follow| follow.follower}
    followers
  end

  def is_fan?
    false
  end

  def featured_songs
    self.songs.featured.limit(6)
  end

  # artist connections
  # has made request to connect with band
  def connection_requested_for? band
    Connection.connection_requested? self, band
  end

  def connected_with? band
    Connection.connected?(self, band)
  end

  def connected_artists page = 1
    Connection.connected_artists_with self, page
  end

  def connections_count
    Connection.connection_count_for self
  end

  def connect_artist band
    Connection.add_connection_between self, band
  end

  def disconnect_artist band
    Connection.remove_connection_between self, band
  end
  
  def connection_requests
    Connection.requested_connections_for self
  end

  # removes the self,
  # removes every items belonged to it
  def remove_me
    self.remove_from_index!
    self.destroy
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