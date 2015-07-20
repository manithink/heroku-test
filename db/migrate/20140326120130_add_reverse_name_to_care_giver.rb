class AddReverseNameToCareGiver < ActiveRecord::Migration
  def change
  	add_column :care_givers, :name_reverse, :string
  end
end
