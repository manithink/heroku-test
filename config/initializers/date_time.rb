class DateTime
	def convert_to(zone = 'Eastern Time (US & Canada)')
		begin
			in_time_zone(zone)
		rescue Exception => e
			in_time_zone('Eastern Time (US & Canada)')
		end
	end

  # #Return difference between two dates expressed in seconds minutes hours and days
  # def self.time_differenece(start_date,end_date)
  # 	begin
  # 		seconds = (end_date.to_i - start_date.to_i).to_f
  #     # return seconds
  #     hours   = seconds / 3600
  # 		return hours
  # 	rescue => e
  # 		0
  # 	end
  # end
end
