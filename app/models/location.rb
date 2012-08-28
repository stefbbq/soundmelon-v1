class Location < ActiveRecord::Base
  belongs_to :item, :polymorphic =>true
  validates :name, :presence =>true

  attr_accessible :formatted_name
  
  before_validation :do_setup

  def formatted_name=(name)
    self.fmt_name = name
    self.name     = self.fmt_name unless self.name
  end

  def do_setup
    self.name     = self.fmt_name unless self.name
    self.is_valid = true if (self.name && self.fmt_name && self.lat && self.lng)
  end

  def should_validate?
    self_item = self.item
    !self_item.blank? && !self_item.last_step?
  end
  
end
