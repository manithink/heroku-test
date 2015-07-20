class AddColumnUptoToEventSeries < ActiveRecord::Migration
  def change
  	add_column :event_series, :upto, :datetime
  end
end
