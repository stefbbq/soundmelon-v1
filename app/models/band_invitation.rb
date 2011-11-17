class BandInvitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :band
  
  validates :email ,:presence => true ,:uniqueness => true
  
  #validates :token, :uniqueness => true
  
  before_create :generate_token
  after_create :send_invitation
  
  def generate_token
      self.token = rand(36**8).to_s(36)+ Time.now.to_i.to_s if self.new_record?
  end
  
  def send_invitation
    UserMailer.mate_invitation_email(self).deliver  
  end 
  
end
