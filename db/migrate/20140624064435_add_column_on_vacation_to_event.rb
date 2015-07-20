class AddColumnOnVacationToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :on_vacation, :boolean, default: false
  end
end
