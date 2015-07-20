class ChangeSchoolYearlimitFromCareGiver < ActiveRecord::Migration
  def change
  	remove_column :care_givers, :school_year_graduated, :integer
  	add_column :care_givers, :school_year_graduated, :integer, :limit => 4
  end
end
