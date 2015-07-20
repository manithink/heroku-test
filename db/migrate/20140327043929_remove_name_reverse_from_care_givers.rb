class RemoveNameReverseFromCareGivers < ActiveRecord::Migration
  def change
  	remove_column :care_givers, :name_reverse, :string
  end
end
