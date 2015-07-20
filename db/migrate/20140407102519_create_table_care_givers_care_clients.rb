class CreateTableCareGiversCareClients < ActiveRecord::Migration
  def change
    create_table :care_clients_givers do |t|
    	t.belongs_to :care_giver
      t.belongs_to :care_client
    end
  end
end
