class State < ActiveRecord::Base
	has_many :care_givers
	has_many :care_clients
	belongs_to :country
end
