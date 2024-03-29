class Venue < ActiveRecord::Base
  include UserEntity
  
  acts_as_messageable
  acts_as_followable
  geocoded_by :mapped_address
  after_validation :geocode, :if => :mapped_address_changed?
  
  has_many :venue_users
  has_many :venue_members, :through => :venue_users, :source => :user
  has_many :venue_admin_users, :through => :venue_users, :source => :user, :conditions =>'access_level = 1'
  has_many :venue_notified_users, :through => :venue_users, :source => :user, :conditions =>'venue_users.access_level = 1 and venue_users.notification_on is true'  
  has_many :artist_shows, :order =>'show_date desc', :dependent =>:nullify
  has_many :albums, :as =>:useritem, :dependent =>:destroy
  has_many :posts, :as =>:useritem, :dependent => :destroy
  has_many :mentioned_posts, :as =>:mentionitem, :dependent => :destroy

  has_many :favorite_items, :as =>:item, :dependent => :destroy
  has_many :colony_memberships, :as =>:member
  has_one  :location, :as =>:item, :dependent =>:destroy
  has_one  :profile_banner, :as =>:profileitem, :dependent =>:destroy
  has_one  :profile_pic, :as =>:profileitem, :dependent =>:destroy
  has_and_belongs_to_many :genres
  
  validates :name, :presence =>:true, :if => lambda { |o| o.first_step? }
  validates :mention_name, :presence =>:true, :if => lambda { |o| o.first_step? }
  validates :city, :presence =>:true, :if => lambda { |o| o.current_step.first == "location" }
  validates :address, :presence =>:true, :if => lambda { |o| o.current_step.first == "location" }

  attr_reader :genre_tokens
  attr_writer :current_step
  
  attr_accessible :genre_tokens, :name, :mention_name, :est_date, :country, :state, :city, :address, :facebook_page, :twitter_page, :info, :approvedattr_accessible, :latitude, :longitude
  accepts_nested_attributes_for :genres

  before_save :set_mapped_address

  def set_mapped_address
    self.mapped_address = [self.address, self.city, self.state, self.country].compact.join(',')     
  end
  
  def genre_tokens=(tokens)
    self.genres = Genre.where(" name in (?)", tokens.split(','))
  end

  def location
    self.mapped_address
  end

  def upcoming_shows_count
    artist_shows.where('show_date >= date(now())').count
  end

  def limited_shows(n=SHOW_DATE_SHOW_LIMIT)
    artist_shows.where('show_date >= date(now())').order('created_at desc').limit(n)
  end
    
  def limited_albums own_access = false, n=2
    own_access ? albums.limit(n) : albums.published.limit(2)
  end

  def limited_followers
    follows   = Follow.where("followable_id = ? and followable_type = ?", self.id, self.class.name).order('RAND()').limit(NO_OF_FOLLOWER_TO_DISPLAY)
    followers = follows.map{|follow| follow.follower}
    followers
  end

  def followers page = 1
    follows   = Follow.where("followable_id = ? and followable_type = ?", self.id, self.class.name).page(page).per(FOLLOWING_FOLLOWER_PER_PAGE)
    follows
  end  

  def get_full_name
    self.name
  end

  def to_param
    self.mention_name
  end
    
  # removes the self,
  # removes every items belonged to it
  def remove_me
    venue_members       = VenueUser.for_venue(self).map(&:user)
    venue_name          = self.get_name    
    self.destroy
    
    # send notification email
    venue_members.each{|venue_member|
      UserMailer.venue_removal_notification_email(venue_member, venue_name, 'member').deliver
    }
  end

  def self.find_venues_from_location location = nil, limit = 5
    if location
      venues = location.find_nearby_venues
    end
    venues  = self.limit(limit) if venues.blank?
    venues
  end

    # steps for artist registration
  def current_step
    @current_step || steps.first
  end

  def steps
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

  def related_venues
    Genre.get_venues_for_genres(self.genres)
  end
  
end
