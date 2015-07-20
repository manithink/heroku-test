class Calendar::CalendarController < ApplicationController

	def delete_service
		case params[:delete_all]
		when 'true'
			@event.event_series.destroy
		when 'future'
			@events = @event.event_series.events.where('starttime > :start_time',
				start_time: @event.starttime.to_formatted_s(:db)).to_a
			@event.event_series.events.delete(@events)
		else
			@event.destroy
		end
		render nothing: true
	end

	def resize_service
		if @event
			@event.endtime = make_time_from_minute_and_day_delta(@event.endtime)
			@event.save
		end
		render nothing: true
	end

	def move_service
		if @event
			@event.starttime = make_time_from_minute_and_day_delta(@event.starttime)
			@event.endtime   = make_time_from_minute_and_day_delta(@event.endtime)
			@event.all_day   = params[:all_day]
			@event.save
		end
		render nothing: true
	end

	private

	def event_params
		params[:event]["starttime"] = parse_datetime(params[:event], 'starttime')
		params[:event]["endtime"] = parse_datetime(params[:event], 'endtime')
		params.require(:event).permit('title', 'description', 'starttime', 'endtime', 'all_day', 'period', 'frequency', 'commit_button')
	end

	def event_series_params
		params[:event]["starttime"] = parse_datetime(params[:event], 'starttime')
		params[:event]["endtime"] = parse_datetime(params[:event], 'endtime')
		params[:event]["upto"] = parse_datetime(params[:event], 'upto')
		params.require(:event).permit('title', 'description', 'starttime', 'endtime', 'all_day', 'period', 'frequency', 'commit_button', 'upto')
	end

	def load_event
		@event = Event.where(:id => params[:id]).first
		unless @event
			render json: { message: "Event Not Found.."}, status: 404 and return
		end
	end

	def make_time_from_minute_and_day_delta(event_time)
		params[:minute_delta].to_i.minutes.from_now((params[:day_delta].to_i).days.from_now(event_time))
	end

	def parse_datetime params, label, utc_or_local = :local
		begin
			year   = params[(label.to_s + '(1i)').to_sym].to_i
			month  = params[(label.to_s + '(2i)').to_sym].to_i
			mday   = params[(label.to_s + '(3i)').to_sym].to_i
			hour   = (params[(label.to_s + '(4i)').to_sym] || 0).to_i
			minute = (params[(label.to_s + '(5i)').to_sym] || 0).to_i
			params.delete("#{label}(1i)")
			params.delete("#{label}(2i)")
			params.delete("#{label}(3i)")
			params.delete("#{label}(4i)")
			params.delete("#{label}(5i)")

			return DateTime.civil(year,month,mday,hour,minute).to_s
		rescue => e
			params.delete("#{label}(1i)")
			params.delete("#{label}(2i)")
			params.delete("#{label}(3i)")
			params.delete("#{label}(4i)")
			params.delete("#{label}(5i)")
			return nil
		end
	end
end
