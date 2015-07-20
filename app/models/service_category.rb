class ServiceCategory < ActiveRecord::Base
	has_many :services, dependent: :destroy
	belongs_to :care_giver_company
	validates :name, uniqueness: { case_sensitive: false, scope: :care_giver_company_id}

	# def category_uniqueness
	# 	current_user.care_giver_company
	# end
end
