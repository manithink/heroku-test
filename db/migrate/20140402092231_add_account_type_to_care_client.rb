class AddAccountTypeToCareClient < ActiveRecord::Migration
  def change
    add_column :care_clients, :account_type, :string
  end
end
