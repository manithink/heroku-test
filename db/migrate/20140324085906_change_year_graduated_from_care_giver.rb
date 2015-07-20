class ChangeYearGraduatedFromCareGiver < ActiveRecord::Migration
  def change
  	remove_column :care_givers, :year_graduated, :date
  	add_column :care_givers, :year_graduated, :integer
  end
end
