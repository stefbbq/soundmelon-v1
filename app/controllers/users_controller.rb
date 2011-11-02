class UsersController < ApplicationController
  before_filter :require_login, :except => [:fan_new, :musician_new, :activate]
  before_filter :logged_in_user, :only => ['fan_new', 'musician_new', :activate]  
  def index
    
  end
  
  def fan_new
    if request.post?
      @user = User.new(params[:user])
      @user.account_type = 0
      if @user.save
        @page_type = 'Fan'
        render 'successful_signup_info' and return
        #redirect_to successful_fan_signup_url, :notice => "Signed up successfully! "
	    else
	       render :fan_new
      end    
    else
      @user = User.new
    end
  end

  def musician_new 
    @error_msg = Array.new
    if request.post?
      
      @user = User.new(params[:user])
      @user.account_type = 1
      if !params[:band_name] || !params[:genre]
         redirect_to root_url and return      
      else  
        if params[:band_name].blank? || params[:genre].blank?
          @errors = true
          @error_msg << "Band Name cannot be blank" if params[:band_name].blank?
          @error_msg << "Genre cannot be blank" if params[:genre].blank?
        end
      end
      
      if @user.valid? && !@errors
         begin
          band = Band.new  
          band_user = BandUser.new
          BandUser.transaction do
            @user.save!
            band.name = params[:band_name].strip
            band.genre = params[:genre].strip
            band.save!
          
            band_user.user_id = @user.id
            band_user.band_id = band.id
            band_user.save!
            @page_type = 'Musician'
            render 'successful_signup_info' and return
          end
         rescue
           render :musician_new
         end
          #redirect_to successful_musician_signup_url, :notice => "Signed up successfully!"
	    else
	       render :musician_new
      end    
    else
      @user = User.new
    end
  end
  
  
  def activate
    if @user = User.load_from_activation_token(params[:id])
      session[:user_id] = @user.id if @user.activate!
      @confirmation_thanks = true
      @additional_info = @user.additional_info
      @payment_info = @user.payment_info
      if @user.account_type
        @page_type = 'Musician'
      else
        @page_type = 'Fan'
      end
      render 'profile/additional_info' and return
      #redirect_to root_url, :notice => 'User was successfully activated.'
    else
      redirect_to root_url, :notice => 'Unable to activate your account. Try Again!'
    end
  end
 
end
