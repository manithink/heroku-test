class AddCustomUrlToAdminSetting < ActiveRecord::Migration
  def change
  	add_column :admin_settings, :custom_url, :string
  end
end
