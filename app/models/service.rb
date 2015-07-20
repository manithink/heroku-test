class Service < ActiveRecord::Base
	belongs_to :service_category
	belongs_to :care_giver_company 
	validates :name, uniqueness: { case_sensitive: false , scope: :care_giver_company_id}
	
	has_many :care_clients_services
	has_many :care_clients, through: :care_clients_services

	def get_option care_client
    care_clients_services.where(care_client_id: care_client.id).first.option
  end

end
