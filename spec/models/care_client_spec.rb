require 'spec_helper'

describe CareClient do
  it "should have a valid factory" do 
  	FactoryGirl.create(:care_client).should be_valid
  end

  it "should not valid without a first name" do
  	FactoryGirl.build(:care_client,first_name: "").should_not be_valid
  end
end
