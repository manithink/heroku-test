class AddZipAndPhoneToCgc < ActiveRecord::Migration
  def change
  	add_column :care_giver_companies, :admin_phone, :string
  	add_column :care_giver_companies, :subscription_zip, :string
  end
end
