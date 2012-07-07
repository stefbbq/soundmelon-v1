class PasswordResetsController < ApplicationController
  skip_before_filter :require_login
  
  def index
    if request.xhr?
      respond_to do |format|
        format.js
      end
    else
      redirect_to root_url and return
    end
  end
  
  def create
    if request.xhr?
      email_user      = User.new(:email =>params[:email])
      email_user.valid?
      is_valid_email  = email_user.errors[:email].blank?
      if is_valid_email        
        user          = User.find_by_email(params[:email])
        # This line sends an email to the user with instructions on how to reset their password (a url with a random token)
        user.deliver_reset_password_instructions! if user
      else
        @status_msg   = "Provided email is invalid"
      end
      respond_to do |format|
        format.js
      end    
      # Tell the user instructions have been sent whether or not email was found.
      # This is to not leak information to attackers about which emails exist in the system.
    else
      redirect_to root_path and return
    end
  end

  def edit
    @user = User.load_from_reset_password_token(params[:id])
    @token = params[:id]
    not_authenticated if !@user
  end
  
  def update
    @token = params[:token] # needed to render the form again in case of error
    @user = User.load_from_reset_password_token(@token)
    not_authenticated if !@user
    # the next line makes the password confirmation validation work
    @user.password_confirmation = params[:user][:password_confirmation]
    # the next line clears the temporary token and updates the password
    if @user.change_password!(params[:user][:password])
      redirect_to(root_path, :notice => 'Password was successfully updated.')
    else
      render :action => "edit"
    end
  end

end