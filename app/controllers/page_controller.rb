class PageController < ApplicationController  
  def show
    @actor      = current_actor
    pages       = ['about', 'contact', 'help', 'terms']
    @page_name  = params[:page_name]    
    unless pages.include?(@page_name)
      render :template =>'/bricks/page_missing' and return
    end
  end

end
