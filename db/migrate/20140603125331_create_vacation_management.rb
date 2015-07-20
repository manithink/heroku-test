class CreateVacationManagement < ActiveRecord::Migration
  def change
    create_table :vacation_managements do |t|
      t.text :reason
      t.references :care_giver
      t.datetime :day
      t.string :status
      t.timestamps
    end
  end
end
