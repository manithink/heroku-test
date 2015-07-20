require 'faker'

FactoryGirl.define do 

	factory :care_giver, :class => CareGiver do |f|
		f.first_name { Faker::Name.first_name }
		f.last_name { Faker::Name.last_name }
    f.address_1 {Faker::Address.street_address}
    f.address_2 {Faker::Address.secondary_address}
    f.country_id 1
    f.state_id 2
    f.city {Faker::Address.city}
    f.zip "12345"
    f.alternative_no "3423423423"
    f.mobile_no "34234234234"
    f.gender "male"
    f.dob  '12/12/1201'
    f.telephony_id "1"
    f.highest_education "222"
    f.school_year_graduated "2322"
    f.college_name "22222"
    f.year_graduated "2321"
    f.certificates "2222"
    f.training "2222"
    f.active_since '12/12/2015'
    f.emergency_first_name "222"
    f.emergency_last_name "222"
    f.emergency_phone_no1 "222333222222"
    f.emergency_phone_no2 "22222222222"
    f.emergency_notes "222222222222222"
    f.care_giver_company_id 2
  end

end 

