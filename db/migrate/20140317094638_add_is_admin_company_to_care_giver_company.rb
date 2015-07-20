class AddIsAdminCompanyToCareGiverCompany < ActiveRecord::Migration
  def change
  	add_column :care_giver_companies, :is_admin_company, :boolean, default: false
  end
end
