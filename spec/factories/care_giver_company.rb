require 'faker'
FactoryGirl.define do
	factory :care_giver_company do |f|
		f.company_name "Qburst"
		f.address_1 {Faker::Address.street_address}
		f.address_2 {Faker::Address.street_address}
		f.city {Faker::Address.city}
		f.pcgc_state 1
		f.pcgc_country 2
		f.zip 45444
		f.phone 8777777777777
		f.fax 8777777777777
		f.website "www.test.com"
		f.year_founded 2004
		f.organistaion_type_id 2
		f.admin_first_name { Faker::Name.first_name }
		f.admin_last_name { Faker::Name.last_name }
		f.admin_email "shamith@qburst.com"
		f.admin_phone 8777777777777
		f.admin_time_zone 'Test Zone'
		f.alt_first_name { Faker::Name.first_name }
		f.alt_last_name { Faker::Name.last_name }
		f.alt_phone 7777777777777
		f.status "active"
		f.subscription_state 1
		f.subscription_address_1 {Faker::Address.street_address}
		f.subscription_address_2 {Faker::Address.street_address}
		f.subscription_city {Faker::Address.city}
		f.subscription_zip 44444
		f.subscription_type_id 1
		f.association :package_type
		# f.package_type_id 2
		f.subscription_country 2
		f.alt_email "shamith@qburst.com"
		f.company_type_id 1
		f.checked 1
	end
end
