class ChangeJobIdArrayToJson < ActiveRecord::Migration
  def change
  	remove_column :assigned_events, :alertreminderjob_ids, :string
  	add_column :assigned_events, :alertreminderjob_ids, :json
  end
end
