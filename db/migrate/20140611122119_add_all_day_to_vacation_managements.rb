class AddAllDayToVacationManagements < ActiveRecord::Migration
  def change
  	add_column :vacation_managements, :all_day, :boolean
  end
end
