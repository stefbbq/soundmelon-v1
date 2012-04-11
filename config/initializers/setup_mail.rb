
ActionMailer::Base.smtp_settings = {
 :user_name => "soundmelon",
  :password => "s0undm3l0n",
 :domain => "soundmelon.com",
 :address => "smtp.sendgrid.net",
 :port => 587,
 :authentication => :plain,
 :enable_starttls_auto => true
}
ActionMailer::Base.default_url_options[:host] = "localhost:3000"
