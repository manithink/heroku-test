class AddLAttitudeLongitudeToAssignedEvent < ActiveRecord::Migration
  def change
  	add_column :assigned_events, :latitude_checkin, :float
  	add_column :assigned_events, :longitude_checkin, :float
  	add_column :assigned_events, :latitude_checkout, :float
  	add_column :assigned_events, :longitude_checkout, :float
  end
end
