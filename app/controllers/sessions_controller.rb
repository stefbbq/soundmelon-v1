class SessionsController < ApplicationController
  before_filter :require_login, :only => [:log_out]
  before_filter :logged_in_user, :only => ['create']    
  def create
    user = login(params[:email], params[:password], params[:remember_me])
    if user      
      redirect_back_or_to fan_home_url
    else
      @user            = User.new
      @failed_login    = 'your email or password was incorrect'
      render :template =>'/fan/signup' and return
    end
  end
  
  def destroy
    logout    
    redirect_to root_url, :notice => 'Logged out'
  end
end