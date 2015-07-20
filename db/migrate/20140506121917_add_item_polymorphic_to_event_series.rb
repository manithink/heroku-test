class AddItemPolymorphicToEventSeries < ActiveRecord::Migration
   def self.up
    change_table :event_series do |t|
      t.references :item, :polymorphic => true
    end
  end

  def self.down
    change_table :event_series do |t|
      t.remove_references :item, :polymorphic => true
    end
  end

end
