class Colony < ActiveRecord::Base

  has_many :colony_memberships, :dependent => :destroy  
  has_many :posts, :as =>:postitem, :dependent => :destroy
  has_one  :profile_pic, :as =>:profileitem, :dependent =>:destroy
  
  validates :name, :presence =>true, :if => lambda { |o| o.current_step.last == 1 }
  validate :should_define_neiche, :if => lambda { |o| o.current_step.last == 2 }
  validates :colony_type, :presence =>true, :if => lambda { |o| o.current_step.last == 3 }

  acts_as_followable

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
    ColonyMembership.create(:is_admin =>is_admin, :member =>item, :approved =>is_approved, :colony_id =>self.id)
  end

  def remove_member item
    membership = ColonyMembership.for_item_and_colony(item, self).first
    membership.destroy if membership
  end 

  def post_for message, writer_user, writer_actor    
    Post.create_post_for(self, writer_user, writer_actor, {:msg =>message})
  end

  # returns all posts associated with colony members
  def all_posts page = 1
    member_venue_ids   = ColonyMembership.venue_members_for(self).map(&:member_id)
    member_artist_ids  = ColonyMembership.artist_members_for(self).map(&:member_id)
    member_user_ids    = ColonyMembership.fan_members_for(self).map(&:member_id)
    Post.where('(postitem_type = ? and postitem_id = ? ) or (useritem_type = ? and useritem_id in (?)) or (useritem_type = ? and useritem_id in(?)) or (useritem_type = ? and useritem_id in(?)) and is_deleted is false', self.class.name, self.id, 'Venue', member_venue_ids, 'Artist', member_artist_ids, 'User', member_user_ids)
        .order('created_at DESC')
        .uniq.paginate(:page =>page, :per_page =>POST_PER_PAGE)
  end 

  def members
    ColonyMembership.members_for(self).map(&:member)
  end

  def member_count
    ColonyMembership.members_for(self).count
  end

  def admin_members
    ColonyMembership.admin_members_for(self).map(&:member)
  end

  def artist_members
    ColonyMembership.artist_members_for(self).map(&:member)
  end

  def artist_member_count
    ColonyMembership.artist_members_for(self).count
  end

  def venue_members
    ColonyMembership.venue_members_for(self).map(&:member)
  end

  def venue_member_count
    ColonyMembership.venue_members_for(self).count
  end

  def fan_members
    ColonyMembership.fan_members_for(self).map(&:member)
  end

  def fan_member_count
    ColonyMembership.fan_members_for(self).count
  end

  def remove_me    
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
