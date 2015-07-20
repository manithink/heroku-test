class AddSignatureToCheckInoutAlert < ActiveRecord::Migration
  def change
  	add_column :check_inout_alerts, :signature, :string
  end
end
