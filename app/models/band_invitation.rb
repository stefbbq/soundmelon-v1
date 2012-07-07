class BandInvitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :band
  
  validates :email, :presence => true # :uniqueness => { :scope => :band_id, :case_sensitive => false, :message => 'has already been invited' } 
  validates :email,  :email_format => true  
  #validates :token, :uniqueness => true
  
  scope :for_artist_id, lambda{|artist_id| where('band_id = ?', artist_id)}
  scope :for_email,  lambda{|email| where('email = ?', email)}

  before_create :generate_token
  after_create :send_invitation
  
  def generate_token
      self.token = rand(36**8).to_s(36)+ Time.now.to_i.to_s if self.new_record?
  end
  
  def send_invitation
    receiver    = User.find_by_email(self.email)
    # if receiver is already a member of soundmelon.com then send him/her internal message to
    if receiver
      band      = Band.find self.band_id
      sender    = User.find self.user_id
      msg       = "Your bandmate #{sender.get_full_name} has invited you to join #{band.name} at soundmelon."
      sender.send_message(receiver, msg, 'Join Invitation From Artist')
      UserMailer.mate_invitation_email(self).deliver
    else
      app_invitation = Invitation.create(:recipient_email =>self.email)
      app_invitation.send_invitation_email
    end        
  end

  def self.create_invitation_for_artist invitee_user, artist, email_user_name_hash_arr
    num_of_sent_invitation = 0
    email_user_name_hash_arr.each{|item|
      type          = item[:type]
      item_value    = item[:name]
      access_level  = item[:level] ? 1 : 0
      user_email    = nil
      if type == 'email'
        user        = User.find_by_email(item_value)
        user_email  = user ? user.email : item_value
      elsif type == 'username'
        user        = User.find_by_mention_name "@#{item_value}"
        user_email  = user.email if user      
      end
      if user_email
        invitation = self.find_by_band_id_and_email artist.id, user_email
        unless invitation
          self.create(
            :user_id      => invitee_user.id,
            :band_id      => artist.id,
            :access_level => access_level,
            :email        => user_email
          )
        end        
        num_of_sent_invitation += 1
      end
    }
    num_of_sent_invitation
  end

  def self.create_invitation_for_artist_and_fan invitee_user, artist, invited_user, access_level = 0
    invitation = self.find_by_band_id_and_email artist.id, invited_user.email
    unless invitation
      self.create(
        :user_id      => invitee_user.id,
        :access_level => access_level,
        :band_id      => artist.id,
        :email        => invited_user.email
      )
    end
  end  
  
end
