class OauthsController < ApplicationController
  skip_before_filter :require_login

  # sends the user on a trip to the provider,
  # and after authorizing there back to the callback url.
  def oauth
    login_at(params[:provider])
  end

  def callback
    provider = params[:provider]
    unless params[:error].present?
      if @user = login_from(provider)
        redirect_to fan_home_path, :notice => "Logged in from #{provider.titleize}!"
      else
        begin
          @user = create_from(provider)
          @user.activate!
          @user.update_attribute(:is_external, true)
          reset_session # protect from session fixation attack
          auto_login(@user)
          redirect_to fan_home_path, :notice => "Logged in from #{provider.titleize}!"
        rescue =>exp
          logger.error "Error in Oauth::Callback :=>#{exp.message}"
          redirect_to root_path, :alert => "Failed to login from #{provider.titleize}!"
        end
      end
    else      
      redirect_to root_path and return
    end
  end

end
