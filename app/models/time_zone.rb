class TimeZone < ActiveRecord::Base
	scope :sort_by_name, -> { order(:name) }
end
