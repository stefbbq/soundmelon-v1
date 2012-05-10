class InvitationsController < ApplicationController
  
  def new
    @invitation = Invitation.new
  end

  def create
    begin
      @invitation             = Invitation.new(params[:invitation])
      @invitation.sender_id   = current_user if current_user
      if @invitation.save
        if current_user
          UserMailer.app_invitation_email(@invitation, fan_registration_url(:invitation_token=>@invitation.token)).deliver
          @sent = true
        else
          @sent = false
        end
      else
        render :action => 'new'
      end      
    rescue =>exp
      logger.info "Error: #{exp.message}"
      render :nothing => true and return
    end
  end
  
end
