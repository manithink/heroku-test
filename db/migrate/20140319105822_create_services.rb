class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name
      t.integer :service_categories_id
      t.integer :care_giver_company_id	
      t.timestamps
    end
  end
end
