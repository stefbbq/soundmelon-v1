class Artist < ActiveRecord::Base
  include UserEntity
  
  acts_as_messageable
  acts_as_followable
  
  has_many :artist_users, :dependent => :destroy
  has_many :artist_members, :through => :artist_users, :source => :user
  has_many :artist_admin_users, :through => :artist_users, :source => :user, :conditions =>'access_level = 1'
  has_many :artist_notified_users, :through => :artist_users, :source => :user, :conditions =>'artist_users.access_level = 1 and artist_users.notification_on is true'
  has_many :albums, :as =>:useritem, :order =>'created_at desc', :dependent =>:destroy
  has_many :artist_shows, :order =>'show_date desc', :dependent =>:destroy
  has_many :artist_musics, :order => 'created_at desc', :dependent =>:destroy
  has_many :artist_invitations, :dependent => :destroy  
  has_many :posts, :as =>:useritem, :dependent => :destroy
  has_many :mentioned_posts, :as =>:mentionitem, :dependent => :destroy
  has_many :songs, :through => :artist_musics
  has_many :favorite_items, :as =>:item, :dependent => :destroy
  has_and_belongs_to_many :genres
  has_one :artist_logo, :dependent =>:destroy
  has_many :artist_influencers
  attr_reader :genre_tokens,:artist_influencer_tokens, :influencer_list
  attr_writer :current_step

  has_one  :location, :as =>:item, :dependent =>:destroy
  has_many :connections, :dependent =>:destroy
  
  has_many :user_item_connections, :as =>:useritem

  accepts_nested_attributes_for :artist_invitations , :reject_if => proc { |attributes| attributes['email'].blank? }
  accepts_nested_attributes_for :genres
  attr_accessible :name, :mention_name, :facebook_page, :genre_tokens, :artist_influencer_tokens, :bio, :website, :twitter_page, :location_attributes, :est_date, :influencer_list
  accepts_nested_attributes_for :location
  
  validates :name, :presence => true
  validates :name, :uniqueness => true
  validates :mention_name, :presence => true
  validates :mention_name, :uniqueness => true

  before_validation :sanitize_mention_name

  searchable :auto_index => true, :auto_remove =>true do
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

  def artist_influencer_tokens=(names)
    names.split(',').each do |name| 
      ArtistInfluencer.find_or_create_by_name_and_artist_id(name, self.id)
    end    
  end

  def sanitize_mention_name
    unless self.mention_name.blank?
      self.mention_name = "#{self.mention_name.parameterize}"
      self.mention_name = nil if self.mention_name.size == 1
    end
  end

  def location_name
    loc = self.location
    loc ? loc.fmt_name : ''
  end
  
  def is_part_of_post? post
    if(post.artist == self || post.mentioned_posts.map{|mentioned_post| mentioned_post.artist.id}.include?(self.id))
      return true
    else
      return false
    end
  end

  def mention_count
    self.mentioned_posts.where('created_at >= ?', MENTION_COUNT_FOR_LAST_N_HOURS.hours.from_now).count
  end

  def artist_musics_count
    self.artist_musics.count
  end

  def songs_count
    self.songs.count
  end

  def self.random_artists limit = 2, except_this_artist = nil
    if except_this_artist
      where('id != ?', except_this_artist.id).order('rand()').limit(limit).uniq
    else
      where('').order('rand()').limit(limit).uniq
    end
  end

  def limited_artist_albums(n=ARTIST_PHOTO_ALBUM_SHOW_LIMIT)
    albums.limit(n)
  end

  def limited_artist_musics(n=ARTIST_MUSIC_SHOW_LIMIT)
    artist_musics.limit(n)
  end

  def limited_artist_members(n=ARTIST_MEMBER_SHOW_LIMIT)
    artist_members.limit(n)
  end

  def limited_artist_shows(n=SHOW_DATE_SHOW_LIMIT)
    artist_shows.where('show_date >= now()').order('created_at desc').limit(n)
  end

  def upcoming_shows_count
    artist_shows.where('show_date >= now()').count
  end

  def limited_artist_featured_songs(n=ARTIST_FEATURED_SONG_LIMIT)
    featured_songs = songs.featured.order('rand()').limit(n)
    featured_songs = songs.order('rand()').limit(3) if featured_songs.empty?
    featured_songs
  end

  def self.find_artist condition_params
    if condition_params[:artist_name]
      where(:mention_name => condition_params[:artist_name]).first
    elsif condition_params[:id]
      where(:id => condition_params[:id]).first
    end
  end

  def self.find_artist_and_members condition_params
    where(:mention_name => condition_params[:artist_name]).includes(:artist_members).first
  end

  def followers page = 1
    follows   = Follow.where("followable_id = ? and followable_type = ?", self.id, self.class.name).page(page).per(FOLLOWING_FOLLOWER_PER_PAGE)
    follows
  end

  def limited_followers
    follows   = Follow.where("followable_id = ? and followable_type = ?", self.id, self.class.name).order('RAND()').limit(NO_OF_FOLLOWER_TO_DISPLAY)
    followers = follows.map{|follow| follow.follower}
    followers
  end

  def featured_songs
    self.songs.featured.limit(6)
  end

#  # artist connections
#  # has made request to connect with artist
#  def connection_requested_for? artist
#    Connection.connection_requested? self, artist
#  end
#
#  def connected_with? artist
#    Connection.connected?(self, artist)
#  end
#
#  def connected_artists page = 1
#    Connection.connected_artists_with self, page
#  end
#
#  def connections_count
#    Connection.connection_count_for self
#  end
#
#  def connect_artist artist
#    Connection.add_connection_between self, artist
#  end
#
#  def disconnect_artist artist
#    Connection.remove_connection_between self, artist
#  end
#
#  def connection_requests
#    Connection.requested_connections_for self
#  end

  # removes the self,
  # removes every items belonged to it
  def remove_me
    artist_members      = ArtistUser.for_artist(self)
    artist_name         = self.get_name
    artist_invitations  = ArtistInvitation.for_artist_id(self.id)
    self.remove_from_index!
    self.destroy

    # remove the existing artist invitations
    artist_invitations.destroy_all

    # send notification email
    artist_members.each{|artist_member|
      UserMailer.artist_removal_notification_email(artist_member, artist_name, 'member').deliver
    }
  end

  def get_full_name
    self.name
  end

  def to_param
    self.mention_name
  end

  # steps for artist registration  
  def current_step
    @current_step || steps.first
  end

  def steps
#    [['basic_info', true, true], ['location', true, true], ['genres', true, true], ['influencer', true, true], ['bandmates', true, true], ['bio', true, true]]
    [['basic_info', true, true], ['location', true, true], ['genres', true, true]]
  end

  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end

  def first_step?
    current_step == steps.first
  end

  def last_step?
    current_step == steps.last
  end

  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end

end
