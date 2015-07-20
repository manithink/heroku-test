class Calendar::CareClientController < Calendar::CalendarController

	before_filter :load_event, only: [:delete_service, :update_service, :edit_service, :resize_service, :move_service]
	before_filter :load_care_client, only: [:get_services, :new_service, :create_service, :index, :create_asigned_event, :assign_pcg_manually, :auto_assign_pcg]

	before_filter :authenticate_user!

	def index
		authorize @care_client, :pcga_can_access_events?
		@care_clients =  current_care_giver_company.care_clients
	end

	def get_services
		@events = @care_client.events.get_events_with_start_and_end_date(params['start'], params['end'])
		events = Event.get_event_json(@events)
		render json: events.to_json
	end

	def new_service
		respond_to do |format|
			format.js
		end
	end

	def create_service
		if params[:event][:period] == "Does not repeat"
			@event = @care_client.events.build(event_params)
		else
			@event = @care_client.event_series.build(event_series_params)
			@event.weekdays = params["weekdays"]
		end

		if @event.save
			render nothing: true
		else
			render json: @event.errors.full_messages.to_sentence, status: 422
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

	def assign_pcg_manually
		@event = @care_client.events.find(params[:event_id])
		@aasigned_event = AssignedEvent.new
		@care_givers = @care_client.available_care_givers_at_timeslots(@event.starttime, @event.endtime)
		render json: { form: render_to_string(partial: 'assign_pcg_manually', locals: { event: @event , care_givers: @care_givers})}
	end

	def create_asigned_event
		if current_care_giver_company.care_givers.where( status: "Active").exists?(assigned_event_params[:care_giver_id])
			care_giver = current_care_giver_company.care_givers.includes(:events).find(assigned_event_params[:care_giver_id])
			cc_event = @care_client.events.find(assigned_event_params[:cc_event_id])
			pcg_events = care_giver.available_events_at_timeslots(cc_event.starttime, cc_event.endtime)

			render json: "HHA is not available at this time slot!!", status: 422 and return if pcg_events.empty?
			pcg_event = pcg_events[0].splitup_events(cc_event)
			assigned_event_params["pcg_event_id"] = pcg_event.id
			@assigned_event	= AssignedEvent.new(assigned_event_params)
			@assigned_event.pcg_event_id = pcg_event.id
			if @assigned_event.save
				cc_event.status = "closed"
				pcg_event.status = "closed"
				cc_event.save
				pcg_event.save
				pcg_event.errors.full_messages.to_sentence
				render :nothing => true
			else
				error_msg =  @assigned_event.errors.messages.values.join(', ')
				render json: error_msg, status: 422
			end
		else
			msg = "No Home Health Aides available at this time!!"
			msg = "Please select a HHA!!" if assigned_event_params[:care_giver_id].empty?
			render json: msg , status: 422 and return
		end
	end

	def remove_pcg
		assigned_event = AssignedEvent.find params[:assigned_event]
		if assigned_event && assigned_event.destroy
			render :nothing => true
		else
			render json: "No Home Health Aides available at this time!!", status: 422 and return unless pcg_event
		end
	end

  #Auto assign PCG to cc and send scheduling summary to PCGA
	def auto_assign_pcg
		Automation.perform_async(@care_client.id)
		render text: "You will get the summary of scheduling to your mail"
	end

	private

	def load_care_client
		@care_client = CareClient.includes(:events).find(params[:id])
	end

	def assigned_event_params
		params.require(:assigned_event).permit(:cc_event_id, :care_client_id, :care_giver_id, :pcg_event_id)
	end
end
