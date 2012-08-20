require 'test_helper'

class UserControllerTest < ActionController::TestCase

  test "should change login redirect to user home path for non-xhr request" do
    get :change_login, nil, {:user_id =>1}
    assert_redirected_to user_home_url, "not redirected to user home path"
  end

  test "change login to artist should set user's artist as the current actor" do
    artist_record         = artists(:artists_001)    
    artist_mention_name   = artist_record.mention_name
    user_id               = 1
    xhr :get, :change_login, {:artist_name => artist_mention_name}, {:user_id => user_id}
    artist        = assigns(:artist)
    is_artist     = assigns(:is_artist)
    assert_not_nil session[:user_id], 'no user logged-in'
    assert_equal user_id, session[:user_id], 'intented user is not logged-in'
    assert_not_nil session[:artist_id], "artist_id session value is nil"
    assert_equal artist.id, session[:artist_id], "artist_id session value is not same as artist id"
    assert_not_nil is_artist
    assert_equal true, is_artist
    assert_template 'change_login'    
  end

  test "change login to self set user as the current actor" do
    user_id = 1
    xhr :get, :change_login, nil, {:user_id => user_id}
    user        = assigns(:user)
    is_fan      = assigns(:is_fan)
    assert_not_nil user, "user has not been instantiated"
    assert_not_nil session[:user_id], 'no user logged-in'
    assert_equal user.id, session[:user_id], 'intented user is not logged-in'
    assert_nil session[:artist_id], 'artist_id session has some value'
    assert_not_nil is_fan
    assert_equal true, is_fan
    assert_template 'change_login'    
  end

  test "index should render home page for fan" do
    get(:index, nil, {:user_id =>1})
    assert_not_nil session[:user_id], 'no user logged-in'
    assert_equal 1, session[:user_id], 'intented user is not logged-in'
    assert_not_nil assigns(:user), 'user has not been instantiated'
  end

  test "index should render home page for artist" do
    get(:index, nil, {:user_id =>1, :artist_id =>1})
    assert_not_nil session[:user_id], 'no user logged-in'
    assert_equal 1, session[:user_id], 'intented user is not logged-in'
    assert_equal 1, session[:artist_id], 'artist_id session has no value'
    assert_not_nil assigns(:artist), 'artist has not been instantiated'
  end

  test "manage profile should render for the current fan" do
    get(:manage_profile, nil, {:user_id =>1})
    assert_not_nil session[:user_id], 'no user logged-in'
    assert_equal 1, session[:user_id], 'intented user is not logged-in'
    assert_not_nil assigns(:user), 'user has not been instantiated'
  end

  test "manage profile should render for the artist" do
    get(:manage_profile,nil, {:user_id =>1, :artist_id =>1})
    assert_not_nil session[:user_id], 'no user logged-in'
    assert_equal 1, session[:user_id], 'intented user is not logged-in'
    assert_equal 1, session[:artist_id], 'artist_id session has no value'
    assert_not_nil assigns(:artist), 'artist has not been instantiated'
  end

  test "pull artist profiles should show all artists for fan" do
    get(:pull_artist_profiles, nil, {:user_id=>1})
    artists        = assigns(:accessible_artists)
    assert_not_nil artists    
  end
end
