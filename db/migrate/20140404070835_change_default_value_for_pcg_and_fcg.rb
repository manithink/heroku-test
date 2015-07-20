class ChangeDefaultValueForPcgAndFcg < ActiveRecord::Migration
  def change
  	change_column :care_clients, :status, :string, default: "Deactive"
  	change_column :care_givers, :status, :string, default: "Deactive" 
  end
end
