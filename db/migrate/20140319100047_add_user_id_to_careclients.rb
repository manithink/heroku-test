class AddUserIdToCareclients < ActiveRecord::Migration
  def change
  	add_column :care_clients, :user_id, :integer
  end
end
