class AddCareGiverCompanyIdToCarePlanSetting < ActiveRecord::Migration
  def change
  	add_column :care_plan_settings, :care_giver_company_id, :integer
  end
end
