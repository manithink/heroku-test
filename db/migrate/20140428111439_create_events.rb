class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.datetime :starttime, :endtime
      t.boolean :all_day, :default => false
      t.text :description
      t.integer :event_series_id
      t.references :item, :polymorphic => true

      t.timestamps
    end

    add_index :events, :event_series_id
  end
end
