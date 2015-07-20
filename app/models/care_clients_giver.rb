class CareClientsGiver < ActiveRecord::Base
  belongs_to :care_client
  belongs_to :care_giver

  before_destroy :remove_future_appointments

  def remove_future_appointments
  	current_time = DateTimeCompare.current_date_time(care_client.get_time_zone)
  	care_client_future_events = care_client.events.joins(:cc_assigned_event).where('starttime  >= :start_time and assigned_events.care_giver_id = :care_giver_id', start_time: current_time, care_giver_id: care_giver_id)
  	care_client_future_events.each do |event|
  		event.cc_assigned_event.destroy
  	end
  end
end


