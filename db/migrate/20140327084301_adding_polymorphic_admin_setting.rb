class AddingPolymorphicAdminSetting < ActiveRecord::Migration
  def change
  	add_column :admin_settings, :care_giver_company_id, :integer
  end
end
