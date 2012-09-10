class OauthsController < ApplicationController
  skip_before_filter :require_login

  # sends the user on a trip to the provider,
  # and after authorizing there back to the callback url.
  def oauth
    if params[:inv_id].present? && !params[:inv_id].blank?
      session[:inv_id]  = params[:inv_id]
      login_at(params[:provider], {:inv_id =>params[:inv_id]})      
    else
      session[:inv_id]  = nil
      login_at(params[:provider])
    end
  end

  def callback
    provider = params[:provider]
    if params[:error].present? or params[:error_code].present?
      redirect_url = root_path      
    else
      user_account_detail = get_user_detail(provider)
      user_detail         = user_account_detail[:user]
      user_email          = user_detail[:email]     
      
      # check if the user is same as intented      
      if session[:inv_id].present?
        inv_id               = session[:inv_id]
        invitation           = Invitation.find_by_token(inv_id)
        invited_email        = invitation.recipient_email
        if invited_email == user_email          
          @user              = User.new(user_detail)
          @user.invitation_token = invitation.token
          @other_user        = false
          render :template =>'fan/signup' and return
        else
          redirect_url       = root_path
          @other_user        = true
        end
        session[:inv_id]     = nil        
      else        
        @user                = User.find_by_email(user_email)
        if @user
          auto_login(@user)
          @existing_user     = true                    
          redirect_url       = fan_home_path
        else
          @user              = User.new
          @is_valid_user     = false
          @no_user           = true
          redirect_url       = root_path
        end        
      end
      respond_to do |format|
        format.js{ redirect_to redirect_url and return}
        format.html{ redirect_to redirect_url and return}
      end      
    end
  end
  
end
