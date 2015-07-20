class CreateAssignedEvents < ActiveRecord::Migration
  def change
    create_table :assigned_events do |t|
      t.references :event
      t.references :care_client
      t.references :care_giver
      t.integer :cc_event_id
      t.integer :pcg_event_id
      t.timestamp :checked_in_at
      t.timestamp :checked_out_at
      t.column :service_record_json, :json
      t.string :status
      t.string :signature_url
      t.timestamps
    end
  end
end
