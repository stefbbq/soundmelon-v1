class ColonyMembership < ActiveRecord::Base
  belongs_to :member, :polymorphic =>true
  belongs_to :colony

  scope :for_item, lambda{|item| where('member_type = ? and member_id = ? ', item.class.name, item.id)}
  scope :for_item_and_colony, lambda{|item, colony| where('member_type = ? and member_id = ? and colony_id = ?', item.class.name, item.id, colony.id)}
  scope :members_for, lambda{|colony| where('colony_id = ? and approved is true', colony.id)}
  scope :admin_members_for, lambda{|colony| where('colony_id = ? and is_admin is true and approved is true', colony.id)}

  attr_accessible :selected, :member, :is_admin, :suspended, :member_id, :member_type
  attr_reader :selected
  attr_writer :selected

  scope :joined, :conditions =>'approved is true'

  def is_admin_membership?
    self.is_admin && !self.suspended
  end

end
