class AddDistanceTravelledToAssignedEvents < ActiveRecord::Migration
  def change
    add_column :assigned_events, :distance_travelled, :integer, default: 0
  end
end
