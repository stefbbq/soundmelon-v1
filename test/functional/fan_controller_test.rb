require 'test_helper'

class FanControllerTest < ActionController::TestCase

  test "signup should redirect to home page for logged-in fan" do
    get(:signup, nil, {:user_id =>1})
    assert_not_nil session[:user_id], "session has no value for current user"
    assert_redirected_to user_home_path
  end

  test "singup on get should prepare the user and artist" do
    get(:signup)
    assert_not_nil assigns(:user), "user object not instantiated"
    assert_not_nil assigns(:artist), "artist object not instantiated"
    assert_response :success
  end

  test "signup should not save a user with duplicate email" do
    user        = users(:users_001)
    user_count  = User.count
    artist_count= Artist.count
    invitation  = invitations(:valid_invitation)
    user_input_params = {
      "invitation_token"      => invitation.token,
      "fname"                 => "fname",
      "lname"                 => "lname",
      "mention_name"          => "mention_name",
      "email"                 => user.email,
      "email_confirmation"    => user.email,
      "password"              => "123456",
      "password_confirmation" => "123456"
    }
    artist_input_params ={"name"=>"", "mention_name"=>""}
    post(:signup, {:user =>user_input_params, :artist =>artist_input_params})
    new_user      = assigns(:user)
    assert_equal false, new_user.valid?, "user object is valid"
    assert_equal 1, new_user.errors.size, "error messages for other fields too"
    assert_not_nil new_user.errors.messages[:email], "no error message for email"
    assert_equal user_count, User.count, "seems that user has been added"
    assert_equal artist_count, Artist.count, "seems that artist has been added"
  end

  test "signup should not save a user without password" do
    invitation  = invitations(:valid_invitation)
    user_input_params = {
      "invitation_token"      => invitation.token,
      "fname"                 => "fname",
      "lname"                 => "lname",
      "mention_name"          => "mention_name",
      "email"                 => 'user_email@user.com',
      "email_confirmation"    => 'user_email@user.com',
      "password"              => "",
      "password_confirmation" => ""
    }
    artist_input_params ={"name"=>"", "mention_name"=>""}
    assert_no_difference(['User.count','Artist.count']) do
       post(:signup, {:user =>user_input_params, :artist =>artist_input_params})
    end
    new_user      = assigns(:user)
    assert_equal false, new_user.valid?, "user object is valid"
    assert_equal 1, new_user.errors.size, "error messages for other fields too"
    assert_not_nil new_user.errors.messages[:password], "no error message for user password"
  end

  test "signup should not save an artist with existing artist name" do
    artist      = artists(:artists_001)
    invitation  = invitations(:valid_invitation)
    user_input_params = {
      "invitation_token"      => invitation.token,
      "fname"                 => "fname",
      "lname"                 => "lname",
      "mention_name"          => "mention_name",
      "email"                 => invitation.recipient_email,
      "email_confirmation"    => invitation.recipient_email,
      "password"              => "123456",
      "password_confirmation" => "123456"
    }
    artist_input_params ={"name"=>artist.name, "mention_name"=>"artist.mention"}
    assert_no_difference(['User.count','Artist.count']) do
      post(:signup, {:user =>user_input_params, :artist =>artist_input_params})
    end
    new_user      = assigns(:user)
    new_artist    = assigns(:artist)
    assert_equal true, new_user.valid?, "user object is invalid"
    assert_equal false, new_artist.valid? , "artist object is valid"
    assert_equal 1, new_artist.errors.size, "more than one error for artist object"
    assert_not_nil new_artist.errors.messages[:name], "no error message for artist name"
  end

  test "signup should not save an artist with existing artist mention name" do
    artist      = artists(:artists_001)
    invitation  = invitations(:valid_invitation)
    user_input_params = {
      "invitation_token"      => invitation.token,
      "fname"                 => "fname",
      "lname"                 => "lname",
      "mention_name"          => "mention_name",
      "email"                 => invitation.recipient_email,
      "email_confirmation"    => invitation.recipient_email,
      "password"              => "123456",
      "password_confirmation" => "123456"
    }
    artist_input_params ={"name"=>'artist.name', "mention_name"=>artist.mention_name}
    assert_no_difference(['User.count', 'Artist.count']) do
      post(:signup, {:user =>user_input_params, :artist =>artist_input_params})
    end
    new_user      = assigns(:user)
    new_artist    = assigns(:artist)
    assert_equal true, new_user.valid?, "user object is invalid"
    assert_equal false, new_artist.valid? , "artist object is valid"
    assert_equal 1, new_artist.errors.size, "more than one error for artist object"
    assert_not_nil new_artist.errors.messages[:mention_name], "no error message for artist mention name"
  end

  test "signup should create only a new fan with valid inputs" do
    artist_count= Artist.count
    invitation  = invitations(:valid_invitation)
    user_input_params = {
      "invitation_token"      => invitation.token,
      "fname"                 => "fname",
      "lname"                 => "lname",
      "mention_name"          => "mention_name",
      "email"                 => invitation.recipient_email,
      "email_confirmation"    => invitation.recipient_email,
      "password"              => "123456",
      "password_confirmation" => "123456"
    }
    artist_input_params ={"name"=>"", "mention_name"=>""}
    assert_difference('User.count') do
      post(:signup, {:user =>user_input_params, :artist =>artist_input_params})
    end
    assert_not_nil assigns(:user)
    assert_equal artist_count, Artist.count, "seems that artist has been added"
  end

  test "signup should create both a fan and artist with valid inputs" do
    invitation  = invitations(:valid_invitation)
    user_input_params = {
      "invitation_token"      =>invitation.token,
      "fname"                 =>"fname",
      "lname"                 =>"lname",
      "mention_name"          =>"mention_name",
      "email"                 =>invitation.recipient_email,
      "email_confirmation"    =>invitation.recipient_email,
      "password"              =>"123456",
      "password_confirmation" =>"123456"
    }
    artist_input_params ={"name"=>"artist_name", "mention_name"=>"artistmention"}
    assert_difference(['User.count','Artist.count']) do
      post(:signup, {:user =>user_input_params, :artist =>artist_input_params})
    end
    assert_not_nil assigns(:user)
  end

  # for valid code
  test "should activate user and auto-login for valid activation code" do
    pending_account = users(:pending_user_account)
    get(:activate, {:id =>pending_account.activation_token})
    user          = assigns(:user)
    assert_not_nil user
    assert_not_nil session[:user_id], "user not logged-in automatically"
    assert_equal user.id, session[:user_id]
    assert_equal 'active', user.activation_state
    assert_redirected_to user_home_path, "not redirected to fan home path"
  end

  # test for invalid code
  test "should not login for invalid activation code" do
    get(:activate, {:id =>'wrong123activation456code789'})
    assert_nil assigns(:user)
    assert_nil session[:user_id]
    assert_redirected_to root_path
    assert_equal 'Unable to activate your account. Try Again!', flash[:notice]
  end
  
end
