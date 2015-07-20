class AddCareGiverCompanyIdToCareclients < ActiveRecord::Migration
  def change
  	add_column :care_clients, :care_giver_company_id, :integer
  end
end
