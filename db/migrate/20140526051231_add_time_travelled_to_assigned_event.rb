class AddTimeTravelledToAssignedEvent < ActiveRecord::Migration
  def change
  	add_column :assigned_events, :time_travelled, :float
  end
end
