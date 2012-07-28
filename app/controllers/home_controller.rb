class HomeController < ApplicationController
  before_filter :logged_in_user, :only => ['index']
  
  def index    
    if current_user
      @user       = current_user
    else      
      @user       = User.new(:invitation_token => params[:invitation_token])
      if @user.invitation
        @user.email               = @user.invitation.recipient_email
        @user.email_confirmation  = @user.invitation.recipient_email
      end
      if request.xhr?
        render :template =>"/bricks/login"
      else
        render :template =>'/fan/signup'
      end      
    end
  end
  
end