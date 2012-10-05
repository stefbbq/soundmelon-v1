class User < ActiveRecord::Base
   
  include UserEntity

  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end
  
  geocoded_by :address
  after_validation :geocode, :if => :address_changed?

  has_many :authentications, :dependent => :destroy
  accepts_nested_attributes_for :authentications

  acts_as_messageable
  acts_as_followable
  acts_as_follower
  
  has_many :user_posts, :order => "created_at desc"  
  has_many :artist_users, :dependent =>:destroy
  has_many :artists, :through => :artist_users
  has_many :admin_artists, :through => :artist_users, :source =>:artist, :conditions => 'access_level = 1'
  has_many :venue_users, :dependent =>:destroy
  has_many :venues, :through => :venue_users, :source =>:venue
  has_many :admin_venues, :through => :venue_users, :source => :venue, :conditions => 'access_level = 1'
  
  has_one  :additional_info, :dependent =>:destroy
  has_one  :location, :as =>:item, :dependent =>:destroy
  has_one  :payment_info
  has_many :artist_invitations
  has_many :albums, :dependent =>:destroy  
  has_many :artist_albums, :dependent =>:destroy
  has_many :artist_photos, :dependent =>:destroy
  has_many :songs
  has_many :song_albums
  has_many :posts, :as=>:useritem, :dependent => :destroy
  has_many :mention_posts
  has_many :mentioned_posts, :as =>:mentionitem
  has_many :playlists, :dependent =>:destroy
  has_many :genre_users, :dependent =>:destroy
  has_many :favorite_items, :as =>:item, :dependent => :destroy
  has_many :colony_memberships, :as =>:member
  has_one  :profile_banner, :as =>:profileitem, :dependent =>:destroy
  has_one  :profile_pic, :as =>:profileitem, :dependent =>:destroy
  has_and_belongs_to_many :genres
  
#  has_many :top_genres,
#    :class_name => 'GenreUser',
#    :order      => 'liking_count',
#    :limit      => 3

  attr_writer :current_step
  attr_accessor :email_confirmation, :password_confirmation, :genre_tokens, :street_address, :city, :state, :country
  attr_accessible :email, :fname, :lname, :email_confirmation, :password, :password_confirmation, :authentications_attributes, :tac, :mention_name, :invitation_token, :is_external, :dob, :gender, :genre_tokens
  attr_accessible :additional_info_attributes
  accepts_nested_attributes_for :additional_info
  attr_accessible :location_attributes
  accepts_nested_attributes_for :location

  validates :email, :presence => true, :if => lambda { |o| o.current_step == o.steps.first }
  validates :fname, :presence => true, :if => lambda { |o| o.current_step == o.steps.first }
  validates :lname, :presence => true, :unless =>:is_external?
  validates :mention_name, :uniqueness => true, :if =>:has_mention_name? #&& lambda { |o| o.current_step == o.steps.first }
  validates :password, :presence => true, :on => :create, :if => lambda { |o| o.current_step == o.steps.first && !o.is_external? }
  validates :password, :confirmation => true, :if => lambda { |o| o.current_step == o.steps.first && !o.is_external? }
  validates :email, :uniqueness => true, :unless =>:is_external?
  validates :email, :confirmation => true, :if => lambda { |o| o.current_step == o.steps.first }
  validates :email, :email_format => true, :if => lambda { |o| o.current_step == o.steps.first }
  validates :tac, :acceptance => true, :if => lambda { |o| o.current_step == o.steps[1] }
  
  before_validation :sanitize_mention_name
  before_create :generate_remember_token
  before_save :set_address
  
  searchable :auto_index => true, :auto_remove =>true do
    text    :fname
    text    :lname
    string  :activation_state
  end
  
  HUMANIZED_ATTRIBUTES = {
    :fname => 'First Name',
    :lname => 'Last Name',
    :tac   => 'Terms and Condition'
  }

  # for the first time, sets the address from different attributes
  def set_address
    self.address = [self.street_address, self.city, self.state, self.country].compact.join(',') unless self.address
  end

  def genre_tokens=(tokens)
    self.genres = Genre.where('name in (?) ', tokens.split(","))
  end

  def current_step
    @current_step || steps.first
  end

  def steps
#    %w[basic_info tac location artist_venue_suggestion social_media]
    %w[basic_info tac]
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

  def self.human_attribute_name(attr,options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end   

  def sanitize_mention_name
    unless self.mention_name.blank?
      self.mention_name = "#{self.mention_name.parameterize}"
      self.mention_name = nil if self.mention_name.size == 1
    end  
  end

  def has_mention_name?
    self.mention_name.present?
  end  
  
  def get_full_name
    "#{self.fname} #{self.lname}"
  end

  def has_address?
    !get_full_address.blank?
  end

  def get_full_address
    self.address
  end
    
  def is_admin_of_artist?(artist) 
    admin_artist_members_id_arr = artist.artist_members.where('artist_users.access_level = 1').map{|artist_member| artist_member.id}
    if admin_artist_members_id_arr.include?(self.id)
      return true
    else
      return false
    end
  end
  
  def is_member_of_artist?(artist)
    artist_members_id_arr = artist.artist_members.map{|artist_member| artist_member.id}
    artist_members_id_arr.include?(self.id) ? true : false
  end
  
  #return all the artists in which the user is admin except the artist that comes as argument
  def admin_artists_list(artist=nil)
    if artist && artist.instance_of?(Artist)
      self.admin_artists.where('artists.id != ?', artist.id)
    else
      self.admin_artists
    end
  end

  def is_admin_of_venue?(venue)
    admin_venue_members_id_arr = venue.venue_members.where('venue_users.access_level = 1').map{|venue_member| venue_member.id}
    admin_venue_members_id_arr.include?(self.id)    
  end

  def is_member_of_venue?(venue)
    venue_members_id_arr = venue.venue_members.map{|venue_member| venue_member.id}
    venue_members_id_arr.include?(self.id) ? true : false
  end

  #return all the venues in which the user is admin except the artist that comes as argument
  def admin_venues_list(venue=nil)
    if venue && venue.instance_of?(Venue)
      self.admin_venues.where('venues.id != ?', venue.id)
    else
      self.admin_venues
    end
  end  
      
  def is_part_of_post? post
    if(post.user == self || post.mentioned_posts.map{|mentioned_post| mentioned_post.user.id}.include?(self.id))
      return true
    else
      return false
    end
  end
  
  # user has genres(collected from user's favourite genre, genres of songs he/she liked)
  # songs from the artists of user's top genres(top based on liking count)
  def find_radio_feature_playlist_songs(number_of_songs = 5)    
    song_items                    = []
#    user_top_genres               = Genre.where('id in (?)',self.top_genre_ids)
    user_top_genres               = self.genres
    artists_from_user_genres      = user_top_genres.map(&:artists).flatten
    albums_of_user_genre_artists  = artists_from_user_genres.map(&:artist_musics).flatten
    for album in albums_of_user_genre_artists
      song_items << album.songs.processed.flatten
    end
    song_items = song_items.flatten    
    song_items = song_items[0, number_of_songs ]    
    # if empty
    song_items = Song.processed(:limit =>number_of_songs) if song_items.empty?
    song_items
  end

  def find_radio_songs excluding_song_ids = [0]
    radio_songs             = []
    fav_genres              = self.genres
    artists_from_fav_genres = fav_genres.map(&:artists).flatten
    artist_musics           = artists_from_fav_genres.map(&:artist_musics).flatten
    radio_songs             = artist_musics.map{|am| am.songs.processed_except(excluding_song_ids)}
    radio_songs.flatten
  end

  def followers page = 1
    self.followers_by_type('User').page(page).per(FOLLOWING_FOLLOWER_PER_PAGE)
  end

  def limited_followers    
    self.followers_by_type('User').order('rand()').limit(NO_OF_FOLLOWER_TO_DISPLAY)
  end

  def assign_admin_role
    self.update_attribute(:user_account_type, USER_TYPE_ADMIN)
  end

  # removes the self,
  # removes every items belonged to it
  # removes every associated artist profiles if they don't belong to anyone else
  def remove_me
    artists = self.artists
    artists.each{|artist|
      # if it belongs to only this user
      if artist.artist_users.size == 1
        artist.remove_me
      end
    }
    full_name   = self.get_full_name
    email       = self.email
    self.remove_from_index!
    self.destroy
    UserMailer.fan_removal_notification_email(full_name, email).deliver
  end

  def name
    self.get_full_name
  end

  def deliver_pending_invitations
    ArtistInvitation.for_email(self.email).each{|bi|
      bi.send_invitation
    }
  end

  def is_active?
    self.activation_state == 'active'
  end

  ######### Invitation Specific Code #########################################################
  validates :invitation_id, :presence =>true, :on =>:create
  validates_uniqueness_of :invitation_id

  has_many :sent_invitations, :class_name => 'Invitation', :foreign_key => 'sender_id'
  belongs_to :invitation, :dependent =>:destroy

  before_create :set_invitation_limit  

  def invitation_token
    invitation.token if invitation
  end

  def invitation_token=(token)
    self.invitation = Invitation.find_by_token(token)
  end
  
  #  private

  def set_invitation_limit
    self.invitation_limit = 5
  end

  ######### Invitation Specific Code #########################################################

  protected
  
  def generate_remember_token
    self.remember_me_token = SecureRandom.urlsafe_base64
  end
  
end