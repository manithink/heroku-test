class ChangeSchoolYearFromCareGiver < ActiveRecord::Migration
  def change
  	remove_column :care_givers, :school_year_graduated, :date
  	add_column :care_givers, :school_year_graduated, :integer
  end
end
