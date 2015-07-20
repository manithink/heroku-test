class Calendar::CareGiverController < Calendar::CalendarController

	before_filter :load_event, only: [:delete_service, :update_service, :edit_service, :resize_service, :move_service]
	before_filter :load_care_giver, only: [:get_services, :new_service, :create_service, :index]

	before_filter :authenticate_user!

	def index
		authorize @care_giver, :pcga_can_access_events?
		@care_givers = current_care_giver_company.care_givers
	end

	def get_services
		zone = current_care_giver_company.get_time_zone
		future_events = @care_giver.events.get_only_future_events(params['start'], params['end'], zone)
		appointments =  @care_giver.events.get_appointments_with_start_and_end_date(params['start'], params['end'])
		# @events = @care_giver.events.get_events_with_start_and_end_date(params['start'], params['end'])
		events = Event.get_event_json(future_events) +  Event.get_event_json(appointments)
		render json: events.to_json
	end

	def new_service
		respond_to do |format|
			format.js
		end
	end

	def create_service
		if params[:event][:period] == "Does not repeat"
			@event = @care_giver.events.build(event_params)
		else
			@event = @care_giver.event_series.build(event_series_params)
			@event.weekdays = params["weekdays"]
		end

		if @event.save
			render nothing: true
		else
			render text: @event.errors.full_messages.to_sentence, status: 422
		end
	end

	def edit_service
		render json: { form: render_to_string(partial: 'edit_service') }
	end

	def update_service
		case params[:event][:commit_button]
		when 'Update All Occurrence'
			@events = @event.event_series.events
			result = @event.update_events(@events, event_params)
		when 'Update All Following Occurrence'
			@events = @event.event_series.events.where('starttime > :start_time',
				start_time: @event.starttime.to_formatted_s(:db)).to_a
			result = @event.update_events(@events, event_params)
		else
			@event.attributes = event_params
			result = []
			result << @event.save
			result << @event.errors.full_messages.to_sentence
		end
		if result[0]
			render nothing: true
		else
			render json: result[1], status: 422
		end
	end

	def remove_cc
		assigned_event = AssignedEvent.find params[:assigned_event]
		if assigned_event && assigned_event.destroy
			render :nothing => true
		else
			render json: "No Home Health Aides available at this time!!", status: 422 and return unless pcg_event
		end
	end

	def manage_vacation_request
		@vacation = VacationManagement.find(params[:event_id])
		render json: { form: render_to_string(partial: 'manage_vacation_request', locals: { vacation: @vacation})}
	end

	def update_vacation_request
		@vacation = VacationManagement.find(params[:vacation][:vacation_id])
		@vacation.status = params[:vacation][:status]
		@vacation.comments = params[:vacation][:comments]
		if @vacation.save
			VacationManagementMailer.delay.send_vacation_status(@vacation.id)
			render :nothing => true
		end
	end

	private

	def load_care_giver
		@care_giver = CareGiver.find(params[:id])
	end

end
