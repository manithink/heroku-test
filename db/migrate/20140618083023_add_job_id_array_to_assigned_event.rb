class AddJobIdArrayToAssignedEvent < ActiveRecord::Migration
  def change
  	add_column :assigned_events, :alertreminderjob_ids, :string, array: true, default: []
  end
end
