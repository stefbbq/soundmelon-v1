class ArtistUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :artist
  scope :for_artist, lambda{|artist| where('artist_id = ?', artist.id)}
  scope :for_artist_id, lambda{|artist_id| where('artist_id = ?', artist_id)}
  scope :for_user, lambda{|user| where('user_id = ?', user.id)}
  scope :for_user_and_artist, lambda{|user, artist| where('user_id = ? and artist_id = ?', user.id, artist.id)}
end
