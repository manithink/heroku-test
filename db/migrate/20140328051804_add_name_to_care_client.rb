class AddNameToCareClient < ActiveRecord::Migration
  def change
  	add_column :care_clients, :name, :string
  end
end
