class BandUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :band
  scope :for_band, lambda{|band| where('band_id = ?', band.id)}
  scope :for_user, lambda{|user| where('user_id = ?', user.id)}
  scope :for_user_and_band, lambda{|user, band| where('user_id = ? and band_id = ?', user.id, band.id)}
end
