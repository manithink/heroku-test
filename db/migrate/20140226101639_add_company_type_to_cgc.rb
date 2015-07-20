class AddCompanyTypeToCgc < ActiveRecord::Migration
  def change
  	add_column :care_giver_companies, :company_type_id, :string
  end
end
