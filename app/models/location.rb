class Location < ActiveRecord::Base
  belongs_to :item, :polymorphic =>true
  validates :name, :presence =>true
  
  attr_accessible :place_name, :name, :lat, :lng, :url
  
  before_validation :do_setup

  def formatted_name=(name)
    self.fmt_name = name
    self.name     = self.fmt_name unless self.name
  end

  def place_name=(name)
    self.fmt_name = name
    self.name     = name.split(',').first
  end

  def do_setup
    self.name     = self.fmt_name unless self.name
    self.is_valid = true if (self.name && self.fmt_name && self.lat && self.lng)
  end

  def should_validate?
    self_item = self.item
    !self_item.blank? && !self_item.last_step?
  end  

  def find_nearby_venues limit = 5
    venues  = []
    name    = self.name
    fm_name = self.fmt_name
    venues
  end
  
end
