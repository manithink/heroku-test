# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# user = User.find_by_email 'farcare.adm@gmail.com'
# unless user
# 	user = User.new
# 	user.email = 'farcare.adm@gmail.com'
# 	user.password = 'farcare123'
user = User.find_by_email 'subramanian@thinkbridge.in'
unless user
	user = User.new
	user.email = 'subramanian@thinkbridge.in'
	user.password = 'viswanathaan6'
	user.approved = true
	a = user.save(validate: false	)
	user.add_role :admin
	company = user.build_care_giver_company(company_name: 'Farcare', is_admin_company: true)
	company.save(validate: false)
	user.confirm!
end



organisation_type = OrganisationType.find_by_name 'Inhome Care'
unless organisation_type
	a = OrganisationType.create :name => 'Inhome Care'
end

organisation_type = OrganisationType.find_by_name 'Home Health'
unless organisation_type
	a = OrganisationType.create :name => 'Home Health'
end

organisation_type = OrganisationType.find_by_name 'Assited Living'
unless organisation_type
	a = OrganisationType.create :name => 'Assited Living'
end

organisation_type = OrganisationType.find_by_name 'Assited Living'
unless organisation_type
	a = OrganisationType.create :name => 'Assited Living'
end

organisation_type = OrganisationType.find_by_name 'Geriatric Care'
unless organisation_type
	a = OrganisationType.create :name => 'Geriatric Care'
end

organisation_type = OrganisationType.find_by_name 'Other'
unless organisation_type
	a = OrganisationType.create :name => 'Other'
end

package_type = PackageType.find_by_name 'Deluxe'
unless package_type
	a = PackageType.create :name => 'Deluxe'
end

subscription_type = SubscriptionType.find_by_name 'Purchase order'
unless subscription_type
	a = SubscriptionType.create :name => 'Purchase order'
end


a = Country.find_or_create_by_name 'USA'
a.states.find_or_create_by_name 'Alabama'
a.states.find_or_create_by_name 'Alaska'
a.states.find_or_create_by_name 'Arizona'
a.states.find_or_create_by_name 'Arkansas'
a.states.find_or_create_by_name 'California'
a.states.find_or_create_by_name 'Colorado'
a.states.find_or_create_by_name 'Connecticut'
a.states.find_or_create_by_name 'Delaware'
a.states.find_or_create_by_name 'Florida'
a.states.find_or_create_by_name 'Georgia'
a.states.find_or_create_by_name 'Hawaii'
a.states.find_or_create_by_name 'Idaho'
a.states.find_or_create_by_name 'Illinois'
a.states.find_or_create_by_name 'Indiana'
a.states.find_or_create_by_name 'Iowa'
a.states.find_or_create_by_name 'Kansas'
a.states.find_or_create_by_name 'Kentucky'
a.states.find_or_create_by_name 'Louisiana'
a.states.find_or_create_by_name 'Maine'
a.states.find_or_create_by_name 'Maryland'
a.states.find_or_create_by_name 'Massachusett'
a.states.find_or_create_by_name 'Michigan'
a.states.find_or_create_by_name 'Minnesota'
a.states.find_or_create_by_name 'Mississippi'
a.states.find_or_create_by_name 'Missouri'
a.states.find_or_create_by_name 'Montana'
a.states.find_or_create_by_name 'Nebraska'
a.states.find_or_create_by_name 'Nevada'
a.states.find_or_create_by_name 'New Hampshire'
a.states.find_or_create_by_name 'New Jersey'
a.states.find_or_create_by_name 'New Mexico'
a.states.find_or_create_by_name 'New York'
a.states.find_or_create_by_name 'North Carolina'
a.states.find_or_create_by_name 'North Dakota'
a.states.find_or_create_by_name 'Ohio'
a.states.find_or_create_by_name 'Oklahoma'
a.states.find_or_create_by_name 'Oregon'
a.states.find_or_create_by_name 'Pennsylvania'
a.states.find_or_create_by_name 'Rhode Island'
a.states.find_or_create_by_name 'South Carolina'
a.states.find_or_create_by_name 'South Dakota'
a.states.find_or_create_by_name 'Tennessee'
a.states.find_or_create_by_name 'Texas'
a.states.find_or_create_by_name 'Utah'
a.states.find_or_create_by_name 'Vermont'
a.states.find_or_create_by_name 'Virginia'
a.states.find_or_create_by_name 'Washington'
a.states.find_or_create_by_name 'West Virginia'
a.states.find_or_create_by_name 'Wisconsin'
a.states.find_or_create_by_name 'Wyoming'

# Event.destroy_all
# EventSeries.destroy_all
# CareGiverCompany.update_all(admin_time_zone: "Eastern Time (US & Canada)")

TimeZone.destroy_all

t = TimeZone.find_or_create_by(name: 'Eastern (UTC-05:00)', value: 'Eastern Time (US & Canada)')
t = TimeZone.find_or_create_by(name: 'Hawaii-Aleutian (UTC-10:00)',  value: 'Hawaii')
t = TimeZone.find_or_create_by(name: 'Alaska (UTC-09:00)', value: 'Alaska')
t = TimeZone.find_or_create_by(name: 'Pacific (UTC-08:00)', value: 'Pacific Time (US & Canada)')
t = TimeZone.find_or_create_by(name: 'Mountain (UTC-07:00)', value: 'Mountain Time (US & Canada)')
t = TimeZone.find_or_create_by(name: 'Central (UTC-06:00)', value: 'Central Time (US & Canada)')
t = TimeZone.find_or_create_by(name: 'Atlantic (UTC-04:00)', value: 'Atlantic Time (Canada)')
t = TimeZone.find_or_create_by(name: 'Newfoundland 	(UTC-03:30)', value: 'Newfoundland')
t = TimeZone.find_or_create_by(name: 'India/Kolkata', value: 'Kolkata')


t = CompanyType.find_or_create_by_name 'Homecare'
t = CompanyType.find_or_create_by_name 'Hospice'
t = CompanyType.find_or_create_by_name 'Independent living'
t = CompanyType.find_or_create_by_name 'Private'
t = CompanyType.find_or_create_by_name 'Nursing Home'
t = CompanyType.find_or_create_by_name 'Home Therapy'
t = CompanyType.find_or_create_by_name 'Home Health'
t = CompanyType.find_or_create_by_name 'Other'

a = Country.find_or_create_by_name 'India'
a.states.find_or_create_by_name 'Andra Pradesh'
a.states.find_or_create_by_name 'Kerala'
a.states.find_or_create_by_name 'Tamilnadu'
a.states.find_or_create_by_name 'Orissa'
a.states.find_or_create_by_name 'Sikkim'
a.states.find_or_create_by_name 'Maharashtra'
a.states.find_or_create_by_name 'Delhi'

a = Country.find_or_create_by_name 'UAE'
a.states.find_or_create_by_name 'Abudhabi'
a.states.find_or_create_by_name 'Dubai'
a.states.find_or_create_by_name 'Sharjah'
a.states.find_or_create_by_name 'Rasalkhaima'

a = Country.find_or_create_by_name 'Canada'
a.states.destroy_all
a.states.find_or_create_by_name "Alberta"
a.states.find_or_create_by_name "British Columbia"
a.states.find_or_create_by_name "Manitoba"
a.states.find_or_create_by_name "New Brunswick"
a.states.find_or_create_by_name "Newfoundland and Labrador"
a.states.find_or_create_by_name "Nova Scotia"
a.states.find_or_create_by_name "Ontario"
a.states.find_or_create_by_name "Prince Edward Island"
a.states.find_or_create_by_name "Quebec"
a.states.find_or_create_by_name "Saskatchewan"

a.states.find_or_create_by_name "Northwest Territories"
a.states.find_or_create_by_name "Yukon"
a.states.find_or_create_by_name "Nunavut"

AdminSetting.create() unless AdminSetting.exists?(1)

# # testing of checkinout.. remove it later.
# # =====================================

# pcg = User.find_by( email: "cyrilgeorgepaul+1@gmail.com" ).care_giver

# pcg_event1 = pcg.events.create(starttime: Time.now, endtime: Time.now+1,title: "test title", description: "test description")
# pcg_event2 = pcg.events.create(starttime: Time.now+1, endtime: Time.now+2,title: "test title", description: "test description")
# pcg_event3 = pcg.events.create(starttime: Time.now+2, endtime: Time.now+3,title: "test title", description: "test description")
# pcg_event4 = pcg.events.create(starttime: Time.now+3, endtime: Time.now+4,title: "test title", description: "test description")
# pcg_event5 = pcg.events.create(starttime: Time.now+4, endtime: Time.now+5,title: "test title", description: "test description")

# cc1 = User.find_by( email: "cyrilgeorgepaul+2@gmail.com" ).care_client
# cc2 = User.find_by( email: "cyrilgeorgepaul+3@gmail.com" ).care_client
# # cc3 = User.find_by( email: "cyrilgeorgepaul+5@gmail.com" ).care_client

# cc1_event1 = cc1.events.create(starttime: Time.now, endtime: Time.now+1,title: "test title", description: "test description")
# cc1_event2 = cc1.events.create(starttime: Time.now+1, endtime: Time.now+2,title: "test title", description: "test description")
# cc2_event1 = cc2.events.create(starttime: Time.now+2, endtime: Time.now+3,title: "test title", description: "test description")
# cc3_event1 = cc2.events.create(starttime: Time.now+3, endtime: Time.now+4,title: "test title", description: "test description")
# cc3_event2 = cc2.events.create(starttime: Time.now+4, endtime: Time.now+5,title: "test title", description: "test description")

# AssignedEvent.create(event_id: cc1_event1.id, care_client_id: cc1.id, care_giver_id: pcg.id,cc_event_id: cc1_event1.id,
# 											pcg_event_id: pcg_event1.id)
# AssignedEvent.create(event_id: cc1_event2.id, care_client_id: cc1.id, care_giver_id: pcg.id,cc_event_id: cc1_event2.id,
# 											pcg_event_id: pcg_event2.id)
# AssignedEvent.create(event_id: cc2_event1.id, care_client_id: cc2.id, care_giver_id: pcg.id,cc_event_id: cc2_event1.id,
# 											pcg_event_id: pcg_event3.id)
# AssignedEvent.create(event_id: cc3_event1.id, care_client_id: cc2.id, care_giver_id: pcg.id,cc_event_id: cc3_event1.id,
# 											pcg_event_id: pcg_event4.id)
# AssignedEvent.create(event_id: cc3_event2.id, care_client_id: cc2.id, care_giver_id: pcg.id,cc_event_id: cc3_event2.id,
# 											pcg_event_id: pcg_event5.id)

# #=================== for testing checkin out ===============