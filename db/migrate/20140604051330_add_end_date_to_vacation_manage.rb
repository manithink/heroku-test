class AddEndDateToVacationManage < ActiveRecord::Migration
  def change
  	add_column :vacation_managements, :startdate, :datetime
  	add_column :vacation_managements, :enddate, :datetime
  	remove_column :vacation_managements, :day
  end
end
