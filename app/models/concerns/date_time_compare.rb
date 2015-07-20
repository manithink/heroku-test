class DateTimeCompare

	def self.is_past? datetime, zone
		# current_date_time = parse_for_compare(DateTime.now.convert_to(zone))
		parse_for_compare(datetime) <= current_date_time(zone)
	end

	def self.compare_two_dates comapred_with, compare_to, operator
		comapred_with.send(operator, compare_to)
	end
	
	def self.is_fifteen_mins_past? datetime, zone
		(parse_for_compare(datetime)+ 15.minutes) <= current_date_time(zone)
	end

	def self.current_date_time zone
		parse_for_compare(DateTime.now.convert_to(zone))
	end

	def self.parse_for_compare datetime
		DateTime.parse("#{datetime.hour}:#{datetime.min}:#{datetime.sec}, #{datetime.day}-#{datetime.month}-#{datetime.year}")
	end
end