class PackageType < ActiveRecord::Base
	has_many :care_giver_companies
end
