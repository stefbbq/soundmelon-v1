class SearchController < ApplicationController
  before_filter :require_login, :except => [:check_bandname]
  
  def index
    @user_search_results = Sunspot.search User do |query| 
      query.keywords params[:q]
      query.with :activation_state, 'active'
    end
    
    @band_search_results = Sunspot.search Band do |query| 
      query.keywords params[:q]
    end
  end
  
  def autocomplete_suggestions
    @users = User.where("fname like :search_word or lname like :search_word", :search_word => "#{params[:term]}%").select('Distinct fname, lname').limit(10)
    @band_names = Band.where("name like :search_word", :search_word => "#{params[:term]}%").select('Distinct name').limit(10).map{|band| band.name}
    @band_genres = Band.where("genre like :search_word", :search_word => "#{params[:term]}%").select('Distinct genre').limit(10).map{|band| band.genre}
    respond_to do |format|
      format.js
    end
  end
  
  def location_autocomplete_suggestions
    @locations = AdditionalInfo.where("location like :search_word ", :search_word => "#{params[:term]}%").select('Distinct location').limit(10)
    respond_to do |format|
      format.js
    end
  end
  
  def check_bandname
    if Band.where('name = ?', params[:band_name]).count == 0
      render :nothing => true, :status => 200 and return
    else
      render :nothing => true, :status => 409 and return
    end
  end
  
end
