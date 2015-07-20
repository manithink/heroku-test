class AddSplitFlagToEvent < ActiveRecord::Migration
  def change
    add_column :events, :is_split_up, :boolean, default: false
  end
end
