class PageController < ApplicationController    

  def show
    pages         = ['about', 'contact', 'help', 'terms']
    @page_name    = params[:page_name]
    begin            
      unless pages.include?(@page_name)
        render :template =>'/bricks/page_missing' and return
      end
    rescue =>exp
      logger.error "Error in Page::Show :=> #{exp.message}"
    end
  end
  
end
