class AdminController < ApplicationController
  before_filter :require_login, :check_admin

  def index
    unless params[:sent]
      @invitations = Invitation.latest_unresponded_invitations.includes(:user)
      @sent_list   = false
    else      
      @invitations = Invitation.latest_sent_invitations.includes(:user)
      @sent_list   = true
    end
  end
    
  def invitation_request_handler
    begin
      @invitation = Invitation.find(params[:id])
    rescue
      @invitation = nil
    end
    if @invitation
      @opcode        = params[:opcode]
      # send the invitation request
      if @opcode == "1"
        @invitation.delay.send_invitation_email
        @invitation.update_attribute(:sent_at, Time.now)
      elsif @opcode == "2"  # ignore the invitation request
        @invitation.destroy
      end
    else
      render :nothing =>true and return
    end
  end

  private

  def check_admin
    is_admin_login = admin_login?    
    unless is_admin_login
      redirect_to user_home_path and return
    end
  end

  
end
