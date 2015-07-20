class ChangeZipTypeToCareGiverCompany < ActiveRecord::Migration
  def change
  	change_column :care_giver_companies, :zip, :string
  end
end
