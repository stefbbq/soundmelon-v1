class UserMailer < ActionMailer::Base
  default from: "merosathilai@gmail.com"

  def activation_needed_email(user)
    @user = user
    @url  = user_activation_url(user.activation_token)
    mail(
      :to => user.email,
      :subject => "Thanks for signing up"
    )
  end

  def activation_success_email(user)
    @user = user
    @url  = root_url
    mail(
      :to => user.email,
      :subject => "Your account is now activated"
    )
  end
  
  def mate_invitation_email(band_invitation)
      @band_invitation  = band_invitation
      @user             = User.find(band_invitation.user_id)
      @new_user_url              = join_band_invitation_url(band_invitation.token,:old_user=>0)
      @old_user_url              = join_band_invitation_url(band_invitation.token,:old_user=>1)
      
      mail(
        :to => band_invitation.email,
        :subject => "#{@user.fname} #{@user.lname}  has invited you to join his/her band at soundmelon  "
      )
      
          
  end
  
  def friend_invitation_email(toemail,user)
      @user = user
      @url  = root_url
      @toemail = toemail
      mail(
        :to => toemail,
        :subject => "#{@user.fname} #{@user.lname}  has invited you to join soundmelon  "
      )
    
  end
  
end
