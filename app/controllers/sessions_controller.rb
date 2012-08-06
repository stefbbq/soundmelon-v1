class SessionsController < ApplicationController
  before_filter :require_login,   :only => [:log_out]
  before_filter :logged_in_user,  :only => [:create]
  
  def create
    user = login(params[:email], params[:password], params[:remember_me])
    if user
      @redirect_url        = params[:return_url] ? params[:return_url] : fan_home_url
      if request.xhr?
        render :js => "window.location.href = '#{@redirect_url}'"
      else
        redirect_back_or_to @redirect_url
      end      
    else
      @user               = User.new
      @failed_login       = 'your email or password was incorrect'
      if request.xhr?        
        render :template  =>'/fan/popuplogin' and return
      else
        render :template  =>'/fan/signup' and return
      end
    end
  end
  
  def destroy
    logout
    cookies.delete(CURRENT_TRACK_VAR_NAME.to_sym)#destroys the currentTrackNumber cookie after logout
    redirect_to root_url, :notice => 'Logged out'
  end
  
end