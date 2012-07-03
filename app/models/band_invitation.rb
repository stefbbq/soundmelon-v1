class BandInvitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :band
  
  validates :email, :presence => true # :uniqueness => { :scope => :band_id, :case_sensitive => false, :message => 'has already been invited' } 
  
  #validates :token, :uniqueness => true
  
  before_create :generate_token
  after_create :send_invitation
  
  def generate_token
      self.token = rand(36**8).to_s(36)+ Time.now.to_i.to_s if self.new_record?
  end
  
  def send_invitation
    # if receiver is already a member of soundmelon.com then send him/her internal message to
    if(receiver = User.find_by_email(self.email))
      band      = Band.find(self.band_id)
      sender    = User.find(self.user_id)
      msg       = "Your bandmate #{sender.get_full_name} has invited you to join #{band.name} at soundmelon. \n Please click the below link to join the band. \n http://soundmelon.com/invitation/accept/1/#{self.token}/join"
      sender.send_message(receiver, msg, 'Join Invitation From Artist')
    end    
    UserMailer.mate_invitation_email(self).deliver  
  end 
  
end
