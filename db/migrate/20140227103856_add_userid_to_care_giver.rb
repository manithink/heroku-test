class AddUseridToCareGiver < ActiveRecord::Migration
  def change
  	add_column :care_givers, :user_id, :integer
  end
end
