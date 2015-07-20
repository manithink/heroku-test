class ServiceTracker < ActiveRecord::Base
	belongs_to :care_client
	belongs_to :care_giver
end
