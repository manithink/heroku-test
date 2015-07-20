class AddMedicalRecordNumberToCareClients < ActiveRecord::Migration
  def change
  	add_column :care_clients, :medical_record_number, :string
  end
end
