class ChangeColumnServicesCategory < ActiveRecord::Migration
  def change
  	rename_column :services, :service_categor_id, :service_category_id
  end
end
