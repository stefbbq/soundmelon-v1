class Venue < ActiveRecord::Base
  include UserEntity
  
  acts_as_messageable
  acts_as_followable

  has_many :venue_users
  has_many :venue_members, :through => :venue_users, :source => :user
  has_many :venue_admin_users, :through => :venue_users, :source => :user, :conditions =>'access_level = 1'
  has_many :venue_notified_users, :through => :venue_users, :source => :user, :conditions =>'venue_users.access_level = 1 and venue_users.notification_on is true'
  has_one :venue_logo, :dependent =>:destroy
  has_many :artist_shows, :order =>'show_date desc', :dependent =>:nullify
  has_many :albums, :as =>:useritem, :dependent =>:destroy
  has_many :posts, :as =>:useritem, :dependent => :destroy
  has_many :mentioned_posts, :as =>:mentionitem, :dependent => :destroy

  has_many :favorite_items, :as =>:item, :dependent => :destroy
  has_one  :location, :as =>:item, :dependent =>:destroy
  has_and_belongs_to_many :genres
  
  validates :name, :presence =>:true, :if => lambda { |o| o.first_step? }
  validates :mention_name, :presence =>:true, :if => lambda { |o| o.first_step? }
  validates :city, :presence =>:true, :if => lambda { |o| o.current_step.first == "location" }
  validates :address, :presence =>:true, :if => lambda { |o| o.current_step.first == "location" }

  attr_reader :genre_tokens
  attr_writer :current_step
  
  attr_accessible :genre_tokens, :name, :mention_name, :est_date, :country, :state, :city, :address, :facebook_page, :twitter_page, :info
  accepts_nested_attributes_for :genres

  def genre_tokens=(ids)
#    self.genre_ids = ids.split(",")
    self.genres = Genre.where(" name in (?)", ids.split(','))
  end

  def location
    [self.address,self.city, self.state, self.country].compact.join(',')
  end

  def upcoming_shows_count
    artist_shows.where('show_date >= date(now())').count
  end

  def limited_shows(n=SHOW_DATE_SHOW_LIMIT)
    artist_shows.where('show_date >= date(now())').order('created_at desc').limit(n)
  end
    
  def limited_albums n=2
    albums.limit(n)
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
    venue_members       = VenueUser.for_venue(self)
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
  
end
