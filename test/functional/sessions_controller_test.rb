require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  
  test "should login for valid credentials" do
    user = users(:users_001)
    post(:create, {:email =>user.email, :password =>'123456'})
    assert_equal user.id, session[:user_id]  
    redirect_url    = assigns(:redirect_url)
    assert_redirected_to redirect_url, "redirected to somewhere else"
  end

  test "should not login for invalid credentials" do    
    post(:create, {:email =>'', :password =>''})
    assert_nil session[:user_id], "session has some value for current user"
    instantiated_user  = assigns(:user)
    login_fail_message = assigns(:failed_login)
    assert_not_nil instantiated_user
    assert_nil instantiated_user.id    
    assert_not_nil login_fail_message
    assert_equal login_fail_message, 'your email or password was incorrect'
    assert_template 'fan/signup'
  end

  test "should remove the session after logout" do
    post :destroy
    assert_nil session[:user_id], "session has some value for current user"
    assert_nil cookies[CURRENT_TRACK_VAR_NAME.to_sym], "didnot remove the cookie for current track"
    assert_equal flash[:notice], 'Logged out', "some other or no message is shown"
    assert_redirected_to root_url, "didn't redirect to root path"    
  end

end
