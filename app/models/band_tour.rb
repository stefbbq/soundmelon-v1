class BandTour < ActiveRecord::Base
  acts_as_votable
  
  belongs_to :band
  validates :tour_date, :presence => true
  validates :venue, :presence => true
  validates :country, :presence => true

  has_many  :posts, :as =>:postitem, :dependent => :destroy

  after_create :create_newsfeed

  def create_newsfeed
    Post.create_newsfeed_for self, nil, self.band_id, " added"
  end

  def artist
    self.band
  end
  
end
