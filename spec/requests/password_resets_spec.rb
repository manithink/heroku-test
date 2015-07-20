require 'spec_helper'

describe "PasswordResets" do
  it "emails user when requesting password reset" do
    user = FactoryGirl.create(:user)
    visit  new_user_session_path
    click_link "Forgot Password ?"
    fill_in "user_email", :with => user.email
    click_button "Send Email"
    page.should have_content("Email sent")
    last_email.to.should include(user.email)
  end

  it "should notify email cant be blank when email field empty" do
    visit  new_user_session_path
    click_link "Forgot Password ?"
    click_button "Send Email"
    page.should have_content("Email can't be blank")
  end

  it "should notify the user email is not valid when email is invalid" do
    user = FactoryGirl.create(:user)
    visit  new_user_session_path
    click_link "Forgot Password ?"
    fill_in "user_email", :with => "invalidemail@example.com"
    click_button "Send Email"
    page.should have_content("Email not found")
  end
  
end
