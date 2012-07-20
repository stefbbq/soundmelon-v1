class ArtistShow < ActiveRecord::Base
  acts_as_votable

  belongs_to :artist, :foreign_key =>'artist_id', :class_name =>'Band'
  validates :show_date, :presence => true
  validates :venue, :presence => true
  validates :city, :presence => true

  has_many  :posts, :as =>:postitem, :dependent => :destroy

  after_create :create_newsfeed

  def create_newsfeed
    Post.create_newsfeed_for self, nil, self.artist_id, " added"
  end

end
