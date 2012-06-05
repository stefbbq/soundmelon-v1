class PageController < ApplicationController    

  def show
    pages         = ['about', 'contact', 'help', 'terms']
    actor         = current_actor
    begin      
      @page_name  = params[:page_name]
      if 'contact' == @page_name
        if actor
          @feedback  = Feedback.new        
        end
      end
      unless pages.include?(@page_name)
        render :template =>'/bricks/page_missing' and return
      end
    rescue =>exp
      logger.error "Error in Page::Show :=> #{exp.message}"
    end
  end
  
end
