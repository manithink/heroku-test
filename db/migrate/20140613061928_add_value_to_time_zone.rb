class AddValueToTimeZone < ActiveRecord::Migration
  def change
  		add_column :time_zones, :value, :string
  end
end
