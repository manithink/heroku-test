class AddParentidToCareclients < ActiveRecord::Migration
  def change
  	add_column :care_clients, :parent_id, :integer
  end
end
