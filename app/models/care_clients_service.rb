class CareClientsService < ActiveRecord::Base
	belongs_to :care_client
	belongs_to :service
	belongs_to :care_giver_company
end