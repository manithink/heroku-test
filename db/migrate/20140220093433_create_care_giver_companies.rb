class CreateCareGiverCompanies < ActiveRecord::Migration
  def change
    create_table :care_giver_companies do |t|
    	t.string :company_name
    	t.string :address_1
    	t.string :address_2
    	t.string :city
    	t.string :state
    	t.string :country
    	t.integer :zip 
    	t.string :phone
    	t.string :fax
    	t.string :website
    	t.integer :year_founded
    	t.integer :organistaion_type_id
    	t.string :admin_first_name
    	t.string :admin_last_name
    	t.string :admin_email
    	t.string :admin_time_zone
    	t.string :alt_first_name
    	t.string :alt_last_name
    	t.string :alt_email
    	t.string :alt_phone
    	t.string :status, default: "Deactive"
    	t.string :subscription_state
    	t.string :subscription_address_1
    	t.string :subscription_address_2
    	t.string :subscription_city
    	t.references :subscription_type
    	t.references :package_type
    	t.references :user
      t.timestamps
    end
  end
end
