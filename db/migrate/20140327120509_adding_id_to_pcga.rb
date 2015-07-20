class AddingIdToPcga < ActiveRecord::Migration
  def change
  	add_column :care_giver_companies, :admin_setting_id, :integer
  end
end
