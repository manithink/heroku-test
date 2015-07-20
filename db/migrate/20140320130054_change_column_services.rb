class ChangeColumnServices < ActiveRecord::Migration
  def change
  	rename_column :services, :service_categories_id, :service_categor_id
  end
end
