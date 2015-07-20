class Country < ActiveRecord::Base
	has_many :care_givers
	has_many :care_clients
	has_many :states
end
