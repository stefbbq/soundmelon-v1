class Genre < ActiveRecord::Base
  acts_as_followable
#  has_many :genre_users
#  has_many :users, :through =>:genre_users
  has_and_belongs_to_many :users
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :venues

  def self.get_artists_for_genres genres, limit = 5
    artists = []
    genres.each do |genre|
      artists << genre.artists.flatten
    end
    artists = Artist.limit(limit) if artists.blank?
    artists.flatten.uniq
  end

  def self.get_venues_for_genres genres, limit = 5
    venues = []
    genres.each do |genre|
      venues << genre.venues.flatten
    end
    venues = Venue.limit(limit) if venues.blank?
    venues.flatten.uniq
  end
  
end
