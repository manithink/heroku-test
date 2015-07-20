class RemoveCountryidFromCareGiver < ActiveRecord::Migration
  def change
  	remove_column :care_givers, :country_id_id, :integer
  	remove_column :care_givers, :state_id_id, :integer
  	add_column :care_givers, :country_id, :integer
  	add_column :care_givers, :state_id, :integer
  end
end
