class CreateCheckInoutAlerts < ActiveRecord::Migration
  def change
    create_table 	 :check_inout_alerts do |t|
    	t.boolean  	 :confirmed_and_actual_notification
    	t.boolean  	 :confirmed_and_actual_warning
    	t.boolean  	 :confirmed_and_actual_alert
    	t.boolean  	 :checkin_and_checkout_notification
    	t.boolean  	 :checkin_and_checkout_warning
    	t.boolean  	 :checkin_and_checkout_alert
    	t.boolean  	 :send_email
    	t.boolean  	 :send_sms
    	t.string   	 :email
    	t.string   	 :sms
    	t.references :care_giver
      t.timestamps
    end
  end
end
