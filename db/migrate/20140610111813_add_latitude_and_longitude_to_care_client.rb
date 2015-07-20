class AddLatitudeAndLongitudeToCareClient < ActiveRecord::Migration
  def change
  	add_column :care_clients, :latitude, :float
  	add_column :care_clients, :longitude, :float
  end
end
