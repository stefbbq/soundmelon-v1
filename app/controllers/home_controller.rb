class HomeController < ApplicationController
  before_filter :logged_in_user, :only => ['index']
  
  def index
    
  end
end
