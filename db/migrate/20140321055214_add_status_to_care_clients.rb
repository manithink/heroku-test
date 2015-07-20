class AddStatusToCareClients < ActiveRecord::Migration
  def change
  	add_column :care_clients, :status, :string
  end
end
