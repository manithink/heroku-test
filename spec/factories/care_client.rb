require 'faker'

FactoryGirl.define do 
	factory :care_client do |cc|
		cc.first_name Faker::Name.first_name
		cc.last_name Faker::Name.last_name
		cc.gender 1
		cc.dob Date.today
		cc.password Faker::Lorem.word
		cc.mobile_no Faker::Number.number(10)
		cc.time_zone "New Delhi"
		cc.country_id "1"
		cc.address_1 Faker::Address.street_name
		cc.address_2 Faker::Address.street_address
		cc.state_id 1
		cc.city Faker::Lorem.word
		cc.zip 45455
		cc.telephony_no Faker::Number.number(10)
		cc.telephone Faker::Number.number(10)
		cc.medical_record_number "#5454525"
	end
end
