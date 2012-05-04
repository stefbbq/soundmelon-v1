class HomeController < ApplicationController
  before_filter :logged_in_user, :only => ['index']
  
  def index
    if current_user
      @user = current_user
    else
      @user = User.new
      render :template =>'/fan/fan_new'
    end
  end
end
