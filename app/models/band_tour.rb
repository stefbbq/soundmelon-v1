class BandTour < ActiveRecord::Base
  acts_as_votable
  
  belongs_to :band
  validates :tour_date, :presence => true
  validates :venue, :presence => true
  validates :country, :presence => true

  has_many  :posts, :as =>:postitem, :dependent => :nullify
  
end
