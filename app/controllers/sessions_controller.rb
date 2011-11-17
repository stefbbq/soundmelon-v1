class SessionsController < ApplicationController
  before_filter :require_login, :only => [:log_out]
  before_filter :logged_in_user, :only => ['create']    
  def create
    user = login(params[:email],params[:password])
    if user
      redirect_back_or_to user_home_url, :notice => 'Logged in'
    else
      redirect_back_or_to root_url, :alert => 'Email or password is invalid'
    end
  end
  
  def destroy
    logout
    redirect_to root_url, :notice => 'Logged out'
  end

end
