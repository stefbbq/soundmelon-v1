class VenueUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :venue
  scope :for_venue, lambda{|venue| where('venue_id = ?', venue.id)}
  scope :for_venue_id, lambda{|venue_id| where('venue_id = ?', venue_id)}
  scope :for_user, lambda{|user| where('user_id = ?', user.id)}
  scope :for_user_and_venue, lambda{|user, venue| where('user_id = ? and venue_id = ?', user.id, venue.id)}
end
