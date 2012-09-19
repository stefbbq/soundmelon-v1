class Colony < ActiveRecord::Base

  has_many :colony_memberships, :dependent => :destroy  
  has_many :posts, :as =>:postitem, :dependent => :destroy
  has_one  :profile_pic, :as =>:profileitem, :dependent =>:destroy
  
  validates :name, :presence =>true, :if => lambda { |o| o.current_step.last == 1 }
  validate :should_define_neiche, :if => lambda { |o| o.current_step.last == 2 }
  validates :colony_type, :presence =>true, :if => lambda { |o| o.current_step.last == 3 }

#  validates :country, :presence =>true
#  validates :city, :presence =>true
#  validates :address, :presence =>true
  
  attr_writer :current_step
  accepts_nested_attributes_for :colony_memberships, :reject_if => lambda { |attributes| attributes['selected'] == "0" }
  def should_define_neiche
    if location_city.blank? and genres.blank? and age_group.blank?
      errors.add(:colony_definition, "should have some value")
    end
  end


  def self.create_for_item item, input_params
    name    = input_params[:name]
    bio     = input_params[:bio]
    type    = input_params[:colony_type]
    country = input_params[:country]
    state   = input_params[:state]
    address = input_params[:address]
    record  = self.create(:name           => name,
                          :bio            => bio,
                          :colony_type    => type,
                          :country        => country,
                          :state          => state,
                          :address        => address)
    unless record.new_record?
      membership        = record.colony_memberships.create(:is_admin =>true, :member =>item)
      membership.save
    end
    record
  end

  def has_this_admin? item
    membership = ColonyMembership.for_item_and_colony(item, self).first
    membership && membership.is_admin_membership?
  end

  def has_this_member? item
    membership = ColonyMembership.for_item_and_colony(item, self).first
    membership
  end

  def add_member item, is_admin = false, is_approved = false
    ColonyMembership.create(:is_admin =>is_admin, :member =>item, :approved =>is_approved)
  end

  def post_for message, writer_user, writer_actor    
    Post.create_post_for(self, writer_user, writer_actor, {:msg =>message})
  end

  def members
    ColonyMembership.members_for(self).map(&:member)
  end

  def admin_members
    ColonyMembership.admin_members_for(self).map(&:member)
  end

  # steps for colony registration
  def current_step
    @current_step || steps.first
  end

  def steps
    [['basic', 1], ['define', 2], ['type', 3]]
  end

  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end

  def first_step?
    current_step == steps.first
  end

  def last_step?
    current_step == steps.last
  end

  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end

  def is_fan?
    false
  end

  def is_venue?
    false
  end

  def is_artist?
    false
  end
  

end
