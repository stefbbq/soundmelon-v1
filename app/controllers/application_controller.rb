class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :http_basic_authenticate

  private
  
  def not_authenticated
    redirect_to root_url, :alert => "First login to access this page."
  end
  
  def logged_in_user
    redirect_to user_home_url and return if current_user
  end

  #added to restrict the site from anonymous access
  def http_basic_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "mustang" && password == "must@ngs0undm3l0n"
    end
  end
  
end
