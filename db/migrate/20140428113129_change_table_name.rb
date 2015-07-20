class ChangeTableName < ActiveRecord::Migration
  def change
  	rename_table :care_client_service_statuses, :care_clients_services
  end
end
