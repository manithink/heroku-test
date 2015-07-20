class AddCareGiverCompanyDetails < ActiveRecord::Migration
  def change
  	add_column :service_categories, :care_giver_company_id, :integer
  end
end
