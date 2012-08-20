require 'test_helper'

class InvitationsControllerTest < ActionController::TestCase

  test "should render new invitation form" do
    xhr :get, :new
    assert_not_nil assigns(:invitation)
    assert_template 'invitations/new'
  end

  test "should create new invitation for valid email from popup" do
    email             = 'invitationemail@gmail.com'
    assert_difference('Invitation.count') do
      xhr :post, :create, :invitation =>{:recipient_email =>email}
    end    
    assert_template 'invitations/create'
  end

  test "should not create new invitation for invalid email from popup" do
    invitation = invitations(:invalid_invitation)
    assert_no_difference('Invitation.count') do
      xhr :post, :create, {:invitation =>{:recipient_email =>invitation.recipient_email}}
    end
    assert_template 'invitations/new'
  end
  
  test "should create new invitation for valid email" do
    email             = 'invitationemail@gmail.com'    
    assert_difference('Invitation.count') do
      xhr :post, :create_invitation, :invitation =>{:recipient_email =>email}
    end
    status_var = assigns(:success)
    assert_not_nil status_var
    assert_equal true, status_var
    assert_template 'invitations/create_invitation'
  end
  
  test "should not create new invitation for invalid email" do
    invitation = invitations(:invalid_invitation)    
    assert_no_difference('Invitation.count') do
      xhr :post, :create_invitation, {:invitation =>{:recipient_email =>invitation.recipient_email}}
    end    
    status_var = assigns(:success)
    assert_not_nil status_var
    assert_equal false, assigns(:success)
    assert_template 'invitations/create_invitation'
  end

end
