class Band < ActiveRecord::Base
  has_many :band_users
  has_many :band_invitations, :dependent => :destroy
  
  accepts_nested_attributes_for :band_invitations, :allow_destroy => :true, :reject_if => proc { |attributes| attributes['email'].blank? }

  searchable do
    text :genre
    text :name
  end
end

