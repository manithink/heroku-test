class CreateServiceTrackers < ActiveRecord::Migration
  def change
    create_table :service_trackers do |t|
      t.references :care_client
      t.references :care_giver
      t.column :service_record_json, :json
      t.timestamp :checkout_time
      t.timestamp :submit_time
      t.string :status
      t.string :signature_url
      t.timestamps
    end
  end
end
