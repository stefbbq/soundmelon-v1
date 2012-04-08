class UserPost < ActiveRecord::Base
  belongs_to :user 
  validates :post ,:presence => true
  before_create :add_space_at_end
  searchable do
    text :post
    boolean :is_deleted
  end
  
  def self.listing user, page = 1   
    conditions = ["is_deleted is false  and user_id = (?) or  post like (?)",user.id,"%@"+user.fname+" %"]
      user_posts = self.where(conditions).paginate(:page =>page, :order =>'created_at desc', :per_page =>10)
    
  end
  
  def add_space_at_end
    self.post = self.post + " " 
  end
end