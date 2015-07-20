class CareGiverCompanyPolicy
	attr_reader :user, :care_giver_company

	def initialize(user, care_giver_company)
		@user = user
		@care_giver_company = care_giver_company
	end

	def index?
		user.has_role? :admin
	end

	def new?
		user.has_role? :admin
	end

	def create?
		user.has_role? :admin
	end

	def change_status?
		user.has_role? :admin
	end

	def delete_company?
		user.has_role? :admin
	end

	def invite_family?
		user.has_role? :pcg
	end

	def settings?
		pcga_access?
	end

	def settings_view_profile?
		pcga_access?
	end

	def settings_change_password?
		pcga_access?
	end

	def care_plan_setting?
		pcga_access?
	end

	def pcga_access?
		user.has_role? :pcga and care_giver_company.user.id.equal?(user.id)
	end
end