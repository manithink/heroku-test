class AddColumnCheckedtoCgc < ActiveRecord::Migration
  def change
  	add_column :care_giver_companies, :checked, :boolean
  end
end
