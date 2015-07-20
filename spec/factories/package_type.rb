FactoryGirl.define do
	factory :package_type do |f|
		sequence(:name) { |n| "Delux-#{n}" }
	end
end