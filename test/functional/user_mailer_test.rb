require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "should send activation needed email" do
    user  = users(:pending_user_account)
    mail  = UserMailer.activation_needed_email(user)
    assert_equal "Thanks for signing up", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["admin@soundmelon.com"], mail.from
  end

  test "should send activation success email" do
    user  = users(:users_001)
    mail  = UserMailer.activation_success_email(user)
    assert_equal "Your account has now been activated", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["admin@soundmelon.com"], mail.from
  end

end
