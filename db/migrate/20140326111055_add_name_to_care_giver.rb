class AddNameToCareGiver < ActiveRecord::Migration
  def change
  	add_column :care_givers, :name, :string
  end
end
