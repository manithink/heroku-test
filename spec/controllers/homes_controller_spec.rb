require 'spec_helper'

describe HomesController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
      response.status.should be(200)
      assert_template :index
  		assert_template layout: "layouts/landing_page"
    end
  end

  describe "Get more info" do
  	it "should sent a mail" do
  		get "index"
  		within get_more_info do
			  fill_in "email", :with => "jonas@elabs.se"
			  fill_in "name", :with => "capybara"
			  click_button "submit"
			end
 		end
	end

end
