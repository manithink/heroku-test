class CreateCareClients < ActiveRecord::Migration
  def change
    create_table :care_clients do |t|
    	t.string  :first_name
    	t.string  :last_name		
    	t.string  :gender
    	t.date 	  :dob
    	t.string  :telephone
    	t.string  :password
    	t.string  :mobile_no
    	t.string  :time_zone
    	t.integer :country_id
    	t.string  :address_1
    	t.string  :address_2
    	t.integer :state_id
    	t.string  :city
    	t.string  :zip
    	t.string  :telephony_no
    	t.string  :last_name
      t.timestamps
    end
  end
end
