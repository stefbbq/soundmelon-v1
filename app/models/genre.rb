class Genre < ActiveRecord::Base
  acts_as_followable
#  has_many :genre_users
#  has_many :users, :through =>:genre_users
  has_and_belongs_to_many :users
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :venues

  def get_artists_for_genres
    artists = self.artists    
  end

end
