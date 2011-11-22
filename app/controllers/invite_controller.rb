class InviteController < ApplicationController
  before_filter :require_login
  
  def fetch_contacts
    if request.xhr?
      @name = params[:email]
      @pass = params[:password]
      begin
        if params[:emailtype]=='Yahoo'
          @contacts = Contacts::Yahoo.new(@name,@pass).contacts
        elsif params[:emailtype]=='Hotmail'
          @contacts = Contacts::Hotmail.new(@name,@pass).contacts
        else
          @contacts = Contacts::Gmail.new(@name,@pass).contacts
       end
      rescue SocketError
        @error = true
        @msg = 'Unable to contact the provider try agian'
      rescue Contacts::AuthenticationError  
         @error = true
         @msg = 'Invalid Username/Password combination. Check and try agian!'
      end
      respond_to do |format|
        format.js and return
      end
   else
    redirect_to user_home_url and return   
   end
  end
  
  def send_invitation
    params[:invite_list].each do |invitee_info|
      invitee_info_arr = invitee_info.split(':$')
      if(invitee_info_arr.size >1)
        toemail = invitee_info_arr.first.to_s
        invitee_full_name = invitee_info_arr.last.to_s
      else
        toemail = invitee_info_arr.first.to_s
        invitee_full_name = ' '
      end
      UserMailer.friend_invitation_email(toemail, invitee_full_name ,current_user).deliver
    end
  end
     
end
