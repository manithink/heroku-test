class CreateAdminSettings < ActiveRecord::Migration
  def change
    create_table :admin_settings do |t|
    	t.text :about_us
    	t.text :contact_us
    	t.string :youtube_url
    	t.string :image_ids, array: true, default: []
    end
  end
end
