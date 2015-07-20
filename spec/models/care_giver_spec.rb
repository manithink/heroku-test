require 'spec_helper'

describe CareGiver do

	it "has a valid factory" do
		FactoryGirl.build(:care_giver).should be_valid
	end

	it "is invalid without valid data" do
		FactoryGirl.build(:care_giver, first_name: '').should_not be_valid
	end

	it "Wrong mobile_no less than 10 digit" do
		FactoryGirl.build(:care_giver, mobile_no: '22222').should_not be_valid
	end

	it "mobile_no grater than 15 digit is valid" do
		FactoryGirl.build(:care_giver, mobile_no: '222888888888888888822').should be_valid
	end


	it "Wrong alternative_no less than 10 digit" do
		FactoryGirl.build(:care_giver, alternative_no: '22222').should_not be_valid
	end

	it "alternative_no grater than 15 digit is valid" do
		FactoryGirl.build(:care_giver, alternative_no: '222888888888888888822').should be_valid
	end

	it "Wrong emergency_phone_no1 less than 10 digit" do
		FactoryGirl.build(:care_giver, emergency_phone_no1: '22222').should_not be_valid
	end

	it "emergency_phone_no1 grater than 15 digit is valid" do
		FactoryGirl.build(:care_giver, emergency_phone_no1: '222888888888888888822').should be_valid
	end

	it "Wrong emergency_phone_no2 less than 10 digit" do
		FactoryGirl.build(:care_giver, emergency_phone_no2: '22222').should_not be_valid
	end

	it "emergency_phone_no2 grater than 15 digit is valid" do
		FactoryGirl.build(:care_giver, emergency_phone_no2: '222888888888888888822').should be_valid
	end
end