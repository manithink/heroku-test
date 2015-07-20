class AddSignDataToAssignedEvent < ActiveRecord::Migration
  def change
  	add_column :assigned_events, :signature, :text
  end
end
