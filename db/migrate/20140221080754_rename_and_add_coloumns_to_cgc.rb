class RenameAndAddColoumnsToCgc < ActiveRecord::Migration
  def change
  	rename_column :care_giver_companies, :country, :pcgc_country
  	rename_column :care_giver_companies, :state, :pcgc_state
  	add_column :care_giver_companies, :subscription_country, :string
  end
end
