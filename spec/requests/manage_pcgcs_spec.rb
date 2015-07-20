require 'spec_helper'

describe "Manage PCGC" do

  before(:each) do 
    admin = FactoryGirl.create(:admin)
    sign_in_as_a_user admin  
  end 

  it "Add PCGC Link in Admin Home Page" do
    visit admin_home_index_path
    click_link "Add PCGC"
    current_path.should eq new_pcga_home_path
    within "h3" do
      page.should have_content "Add PCGC"
    end
  end

 it "Setting page for Admin to set Landing page" do
  visit admin_home_index_path
  click_link 'settings'
  expect(page).to have_content("Settings")
  end
end
