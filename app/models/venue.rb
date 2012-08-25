class Venue < ActiveRecord::Base
  include UserEntity
  
  acts_as_messageable
  acts_as_followable

  has_many :venue_users
  has_many :venue_members, :through => :venue_users, :source => :user
  has_many :venue_admin_users, :through => :venue_users, :source => :user, :conditions =>'access_level = 1'
  has_many :venue_notified_users, :through => :venue_users, :source => :user, :conditions =>'venue_users.access_level = 1 and venue_users.notification_on is true'
  has_one :venue_logo
  has_many :artist_shows, :order =>'show_date desc', :dependent =>:nullify
  has_many :albums, :as =>:useritem, :dependent =>:destroy
  has_many :posts, :as =>:useritem, :dependent => :destroy
  has_many :mentioned_posts, :as =>:mentionitem, :dependent => :destroy

  validates :name, :presence =>:true
  validates :address, :presence =>:true

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
  
end
