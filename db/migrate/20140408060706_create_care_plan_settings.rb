class CreateCarePlanSettings < ActiveRecord::Migration
  def change
    create_table :care_plan_settings do |t|
    	t.boolean :farcare_tracker_used
    	t.boolean :detect_late_checkout
    	t.string :end_of_week
      t.timestamps
    end
  end
end
