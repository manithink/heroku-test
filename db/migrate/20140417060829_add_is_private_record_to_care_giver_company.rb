class AddIsPrivateRecordToCareGiverCompany < ActiveRecord::Migration
  def change
  	add_column :care_giver_companies, :is_private_record, :boolean, default: false
  end
end
