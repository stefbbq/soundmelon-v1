class InvitationsController < ApplicationController
  
  def new
    @has_source   = params[:source] && params[:source]=='1'    
    @invitation   = Invitation.new
  end

  def create
    begin
      @invitation             = Invitation.new(params[:invitation])      
      @sent                   = false
      @from_page              = params[:from_page].present? && params[:from_page]=='1'
      @has_message            = params[:source] && params[:source] == "1"
      if @invitation.save
        unless current_user
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

  def login_or_invitation    
    @return_url   = params[:artist_name] ? show_artist_url(params[:artist]) : root_url
  end

  def create_invitation
    begin
      @invitation             = Invitation.new(params[:invitation])
      @success                = false
      if @invitation.save        
        @success = true
      end
    rescue =>exp      
      logger.info "Error: #{exp.message}"
      render :nothing => true and return
    end
  end
  
end
