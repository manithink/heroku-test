class AddCommentsToVacationManagements < ActiveRecord::Migration
  def change
  	add_column :vacation_managements, :comments, :string
  end
end
