class CreateCareClientServiceStatus < ActiveRecord::Migration
  def change
    create_table :care_client_service_statuses do |t|
    	t.integer :care_client_id
    	t.integer :service_id
    	t.string :option
    	t.timestamps
    end
  end
end
