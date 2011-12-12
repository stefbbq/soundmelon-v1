class AdditionalInfo < ActiveRecord::Base
  belongs_to :user
  attr_protected  :user_id
  validates :location, :presence => true
  
  searchable do
    text :location
    text :favourite_genre
  end
end
