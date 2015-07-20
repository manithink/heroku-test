class AddCurrentCareGiverCompanyIdToCareClientServiceStatus < ActiveRecord::Migration
  def change
  	add_column :care_client_service_statuses, :care_giver_company_id, :integer
  end
end
