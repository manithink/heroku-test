class ChangeCompanyIdToInteger < ActiveRecord::Migration
  def change
  	remove_column :care_giver_companies, :company_type_id, :string
  	add_column :care_giver_companies, :company_type_id, :integer 	
  end
end
