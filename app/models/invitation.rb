class Invitation < ActiveRecord::Base
  has_one :user
  belongs_to :sender, :class_name => 'User'
  has_one :recipient, :class_name => 'User'

  validates :recipient_email, :presence =>true
  validates :recipient_email, :uniqueness => true
  validate :recipient_is_not_registered
  validate :sender_has_invitations, :if => :sender

  before_create :generate_token
  before_create :decrement_sender_count, :if => :sender

  scope :latest_unresponded_invitations, :conditions=>["sent_at is null"]
  scope :latest_sent_invitations, :conditions=>["sent_at > ?", Time.now - 15.days ]

  def send_invitation_email
    UserMailer.app_invitation_email(self).deliver
    self.update_attribute(:sent_at, Time.now)
  end

  private

  def recipient_is_not_registered
    errors.add :recipient_email, 'is already registered' if User.find_by_email(recipient_email)
  end

  def sender_has_invitations
    unless sender.invitation_limit > 0
      errors.add_to_base 'You have reached your limit of invitations to send.'
    end
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def decrement_sender_count
    sender.decrement! :invitation_limit
  end
  
end
