class Pcg::VacationManagementController < ApplicationController
  before_filter :authenticate_user!

  def index    
    @care_giver = CareGiver.find(params[:id])
    # render :nothing  =>  true
    authorize @care_giver
  end

  def new_vacation
    @vacation = VacationManagement.new
    respond_to do |format|
      format.js
    end
  end

  def create_vacation
    @vacation = VacationManagement.new(vacation_params)
    @vacation.status = "pending"
    if @vacation.save  
      VacationManagementMailer.delay.send_pcg_request(@vacation.id)  
      render :nothing =>  true
    else
      render text: @vacation.errors.full_messages.to_sentence, status: 422
    end
  end

  def get_vacation_details
    @care_giver = CareGiver.find(params[:id])
    @vacations = @care_giver.vacation_managements.get_vacations_with_start_and_end_date(params['start'], params['end'])
    if(params[:filter].present? && params[:filter] == "hide_rejected")
      @vacations = @vacations.where("status != ?", 'rejected')
    end
    data = VacationManagement.get_event_json(@vacations)
    render json: data.to_json
  end

  def edit_vacation
    @vacation = VacationManagement.find(params[:vacation_id])
    render json: { form: render_to_string(partial: 'edit_vacation') }
  end

  def update_vacation
    @vacation = VacationManagement.find(params[:vacation_id])
    @vacation.update_attributes(vacation_params)
    @vacation.status = "pending"
    if @vacation.save  
      VacationManagementMailer.delay.send_pcg_request(@vacation.id) 
      render :nothing =>  true
    else
      render text: @vacation.errors.full_messages.to_sentence, status: 422
    end
  end

  def resize_vacation
    @vacation = VacationManagement.find(params[:event_id])
    if @vacation
      @vacation.enddate = make_time_from_minute_and_day_delta(@vacation.enddate)
      @vacation.status = "pending"
      @vacation.comments = nil
      if @vacation.save
        VacationManagementMailer.delay.send_pcg_request(@vacation.id)  
      end
    end
    render nothing: true
  end

  def delete_vacation
    @vacation = VacationManagement.find(params[:id])
    if @vacation
      @vacation.destroy
    end
    render nothing: true
  end

  def move_vacation
    @vacation = VacationManagement.find(params[:event_id])
    if @vacation
      @vacation.startdate = make_time_from_minute_and_day_delta(@vacation.startdate)
      @vacation.enddate   = make_time_from_minute_and_day_delta(@vacation.enddate)
      @vacation.all_day   = params[:all_day]
      @vacation.status = "pending"
      @vacation.comments = nil
      if @vacation.save
        VacationManagementMailer.delay.send_pcg_request(@vacation.id)
      end
    end
    render nothing: true
  end

  def make_time_from_minute_and_day_delta(event_time)
    params[:minute_delta].to_i.minutes.from_now((params[:day_delta].to_i).days.from_now(event_time))
  end

  def current_care_client_events
    @care_giver = CareGiver.find(params[:id])
    @care_client = CareClient.find(params[:care_client_id])
    authorize @care_giver
    authorize @care_client
  end

  def get_current_care_client_events
    @care_client = CareClient.find(params[:care_client_id])
    @assigned_event_ids = @care_client.assigned_events.where(:care_giver_id => params[:id]).pluck(:cc_event_id)
    @events = Event.where(:id => @assigned_event_ids)
    events = Event.get_event_json(@events)
    render json: events.to_json
  end


	private

  def vacation_params
    params.require(:vacation).permit(:reason, :startdate, :enddate, :status, :care_giver_id, :all_day, :comments )
  end
end
