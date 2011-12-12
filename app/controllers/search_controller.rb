class SearchController < ApplicationController
  before_filter :require_login
  
  def index
    @user_search_results = Sunspot.search User do |query| 
      query.keywords params[:q]
      query.with :activation_state, 'active'
    end
    
    @band_search_results = Sunspot.search Band do |query| 
      query.keywords params[:q]
    end
  end
end
