class AdminSetting < ActiveRecord::Base
	belongs_to :care_giver_company

	validates :custom_url, :uniqueness => true, :presence => true, :length => {:maximum => 50}
	before_save :optimise_data


	def optimise_data
		self.about_us = self.about_us.to_s.gsub("\n","").gsub("\r","").gsub('"', "'")
		self.contact_us = self.contact_us.to_s.gsub("\n","").gsub("\r","").gsub('"', "'")
	end

	def update_admin_settings(params)
		data = params[:content].gsub("\n","").gsub('"', "'")
		if params[:item] == "about_us"
      update_attributes(:about_us => data)
    elsif params[:item] == "contact_us"
      update_attributes(:contact_us => data)
    elsif params[:item] == "url"
      update_attributes(:youtube_url => params[:content])
    end
	end

end