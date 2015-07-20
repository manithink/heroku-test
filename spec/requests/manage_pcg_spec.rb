require 'spec_helper'

describe "Manage PCG" do

	before(:each) do 
		pcga = FactoryGirl.create(:pcga)
		sign_in_as_a_user pcga
		ApplicationController.any_instance.stub(:current_care_giver_company).and_return(pcga.care_giver_company)
	end	

	it "Home page of PCGA - Can access PCG creation link" do
		visit pcga_home_index_path
		click_on "Add PCG"
		current_path.should eq new_pcg_home_path
		within "h3" do
			page.should have_content "Add PCG"
		end
	end

	it "Fill without data" do
		visit new_pcg_home_path
		click_button "Submit"
		current_path.should eq '/pcg/home'
		within "h3" do
			page.should have_content "Add PCG"
		end
	end


	it 'On Click Signout button, redirect to root url' do
		visit new_pcg_home_path
		click_link "Logout"
		expect(page.current_path).to eql root_path
	end

end

