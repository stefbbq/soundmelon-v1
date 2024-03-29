class ArtistShow < ActiveRecord::Base
  include UserContent
  
  acts_as_votable

  belongs_to :artist
  belongs_to :venue
  validates :show_date, :presence => true
  validates :venue_name,:presence => true
  validates :city,      :presence => true

  has_many  :posts, :as =>:postitem, :dependent => :destroy

  before_save :update_venue
  
  after_create :create_newsfeed

  def get_venue_name
    self.venue_name
  end

  def update_venue
    venuename = self.venue_name
    venue = Venue.find_by_name venuename
    if venue
      self.venue_id = venue.id if venue
    else
      new_venue     = Venue.new(:name =>venuename, :approved =>false, :city =>self.city)
      new_venue.save(:validate =>false)
    end
  end

  def create_newsfeed
    Post.create_newsfeed_for self, nil, 'Artist', self.artist_id, " created"
  end

  def useritem
    self.artist
  end

  def is_past_show?
    self.show_date <=Date.today
  end
end
