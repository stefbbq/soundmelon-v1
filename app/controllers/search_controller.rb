class SearchController < ApplicationController
  before_filter :require_login, :except => [:check_artistname, :check_artistmentionname, :check_fanusername]
  
  def index
    @actor                = current_actor
    if params[:a_page].blank? # only fan search      
      @fan_search_results = User.search do
        fulltext params[:q]
        with(:activation_state, 'active')
        paginate :page => params[:f_page], :per_page => SEARCH_FAN_RESULT_PER_PAGE
      end    
    end
    
    if params[:f_page].blank? # only artist search      
      @artist_search_results = Artist.search do
        fulltext params[:q]
        paginate :page => params[:a_page], :per_page => SEARCH_ARTIST_RESULT_PER_PAGE
      end
    end

    messages_and_posts_count
    
    respond_to do |format|
      format.js
      format.html
    end
  end
  
  def autocomplete_suggestions
    @users            = User.where("activation_state = 'active' and (fname like :search_word or lname like :search_word)", :search_word => "#{params[:term]}%").select('Distinct fname, lname').limit(10)
    @artist_names     = Artist.where("name like :search_word", :search_word => "#{params[:term]}%").select('Distinct name').limit(10).map{|artist| artist.name}
    @artist_genres    = Artist.where("genre like :search_word", :search_word => "#{params[:term]}%").select('Distinct genre').limit(10).map{|artist| artist.genre}
    respond_to do |format|
      format.js
    end
  end
  
  def location_autocomplete_suggestions
    @locations        = AdditionalInfo.where("location like :search_word ", :search_word => "#{params[:term]}%").select('Distinct location').limit(10)
    respond_to do |format|
      format.js
    end
  end
  
  def check_fanusername
    if User.where('mention_name = ?', "#{params[:fan_user_name]}").count == 0
      status_code = 200
    else
      status_code = 409
    end    
    render :nothing =>true, :status =>status_code and return
  end

  def check_artistname
    if Artist.where('name = ?', params[:artist_name]).count == 0
      status_code = 200
    else
      status_code = 409
    end
    render :nothing =>true, :status =>status_code and return
  end

  def check_artistmentionname
    if Artist.where('mention_name = ?', "#{params[:artist_mention_name]}").count == 0
      status_code = 200
    else
      status_code = 409
    end
    render :nothing =>true, :status =>status_code and return
  end
  
end
