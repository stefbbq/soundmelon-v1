class FeedbackTopic < ActiveRecord::Base
  validates :name, :presence =>true

  has_many :feedbacks


  def self.add_topic input_params
    create(:name =>input_params[:name], :emails =>input_params[:emails])
  end

end
