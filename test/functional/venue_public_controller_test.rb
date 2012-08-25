require 'test_helper'

class VenuePublicControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get shows" do
    get :shows
    assert_response :success
  end

end
