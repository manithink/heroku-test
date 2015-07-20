class AddCareGiverCompanyidToCareGiver < ActiveRecord::Migration
  def change
  	add_column :care_givers, :care_giver_company_id, :integer
  end
end
