class AddStatusToPcg < ActiveRecord::Migration
  def change
  	add_column :care_givers, :status, :string
  end
end
