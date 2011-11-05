require 'test_helper'

class ProfileControllerTest < ActionController::TestCase
  test "should get additional_info" do
    get :additional_info
    assert_response :success
  end

end
