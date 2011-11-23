class AdditionalInfo < ActiveRecord::Base
  belongs_to :user
  attr_protected  :user_id
  validates :location, :presence => true
end
