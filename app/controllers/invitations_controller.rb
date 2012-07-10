class InvitationsController < ApplicationController
  
  def new
    @invitation = Invitation.new    
  end

  def create
    begin
      @invitation             = Invitation.new(params[:invitation])
      @invitation.sender_id   = current_user if current_user
      @sent                   = false
      @from_page              = params[:from_page].present? && params[:from_page]=='1'
      if @invitation.save
        if current_user
#          @invitation.send_invitation_email
#          @sent = true
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
