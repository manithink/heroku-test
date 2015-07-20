class ChangeHstoreToCarePlanSetting < ActiveRecord::Migration
  def change
  	add_column :care_plan_settings, :alerts, :hstore 
  	add_column :care_plan_settings, :telephony, :hstore 
  end
end
