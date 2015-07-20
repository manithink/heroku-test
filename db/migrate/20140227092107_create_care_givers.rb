class CreateCareGivers < ActiveRecord::Migration
  def change
    create_table :care_givers do |t|
    	t.string      :first_name
    	t.string      :last_name
    	t.string      :address_1
    	t.string      :address_2
    	t.references  :country_id
    	t.references  :state_id
    	t.string      :city
 			t.string      :zip
 			t.string      :alternative_no
 			t.string      :mobile_no
 			t.string      :gender
 			t.date        :dob
 			t.string      :telephony_id
 			t.string      :highest_education
 			t.date        :school_year_graduated
 			t.string      :college_name
 			t.date        :year_graduated
 			t.text        :certificates
 			t.text        :training
 			t.date        :active_since
 			t.string      :emergency_first_name
 			t.string      :emergency_last_name
 			t.string      :emergency_phone_no1
 			t.string      :emergency_phone_no2
 			t.text        :emergency_notes
      t.timestamps
    end
  end
end
