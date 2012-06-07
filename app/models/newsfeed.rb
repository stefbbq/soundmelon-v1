class Newsfeed < ActiveRecord::Base
  belongs_to :newsitem, :polymorphic =>true

  


  
end
