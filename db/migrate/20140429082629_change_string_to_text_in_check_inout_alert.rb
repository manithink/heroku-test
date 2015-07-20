class ChangeStringToTextInCheckInoutAlert < ActiveRecord::Migration
  def change
  	change_column :check_inout_alerts, :signature, :text
  end
end
