require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  
  test "not logged in user should redirect to login page" do
    get :index
    assert_not_nil assigns(:user)
    assert_template 'fan/signup'
  end

  test "logged in user should redirect to home page" do
    get :index, nil, {:user_id =>1}
    actor         = assigns(:actor)
    assert_not_nil actor
    assert actor.instance_of?(User)    
    assert_not_nil session[:user_id], "no user id in session"
    assert_equal actor.id, session[:user_id]
    assert_redirected_to user_home_url
  end

  test "should render login on xhr request" do
    xhr :get, :index
    assert_template 'bricks/login'
  end
  
end
