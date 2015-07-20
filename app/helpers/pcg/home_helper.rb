module Pcg::HomeHelper

	def is_required?(record, id)
		if record
			'<span class="mandatory">*</span>'.html_safe if record.care_clients_services.where(care_client_id: id).first.option.eql?("required") rescue nil
		end
	end

	#Check boolean
	def to_boolean val
		val.eql?("true") ? true : false
	end
	
	#Get Event of a care client
	def event_care_client(event)
		CareClient.find(event.care_client_id)
	end

	def signature_helper(assigned_event)
		if assigned_event.signature
			'<div class="sign"><p>Sd/-<br/>'.html_safe + assigned_event.care_client.fullname.html_safe + '</p>'.html_safe+(image_tag "/signatures/#{assigned_event.id}.png")+'</div>'.html_safe
	       
	       
		else
			'<div class="row">
	      <div class="m-signature-pad" id="signature-pad">
	        <button data-action="clear" class="button clear">Clear</button>
	        <div class="m-signature-pad--body">
	        	<div class="canvas-div canvas-overlay">
	          <canvas height=200></canvas>
	          </div>
	        </div>
	      </div>
	    </div>'.html_safe
	  end
	end

	def sign assigned_event
		if assigned_event.signature
			'<p>I acknowledge that '.html_safe +  assigned_event.care_giver.fullname.html_safe + ' has provided me, the above-mentioned services.<span class="canvas-error">&nbsp;</span></p><div class="noSignature">&nbsp;</div><div class="sign"><p>Sd/-<br/>'.html_safe + assigned_event.care_client.fullname.html_safe + '</p>'.html_safe+(image_tag "/signatures/#{assigned_event.id}.png")+'</div>'.html_safe
		else
			'<div class="noSignature"><span class="mandatory">Client not yet approved your work!</span></div>'.html_safe
		end
	end

	def check_in_check_out_botton record
		edit_path = pcg_edit_my_services_path(record.id)
		view_path = pcg_view_my_services_path(record.id)
		
		case record.status
		when "checked_in"
			link_to "Continue", edit_path, class: "service-btn"
		when "checked_out"
			link_to "Continue", edit_path, class: "service-btn"
		when "continue"
			link_to "Continue", edit_path, class: "service-btn"
		when "submitted"		
			link_to "View", view_path, class: "service-btn"
		else
			link_to "View", view_path, class: "service-btn"
		end
	end 

	def checkin_checkout_button_group (record,app)
		cls = (app == "web")? "check-in" : "check-out"
		status = record.status
		case status
		when "checked_in"
			'<input type="button" value="Save & Continue" class="farCare-btn save-continue first-btn" >
			<button type="button" value="Check-out" class="farCare-btn '.html_safe+ cls +' inactive" >Check-out</button>
			<input type="button" value="Get Signature" class="farCare-btn get-signature inactive" >'.html_safe
		when "checked_out"
			'<a href=""><input type="button" value="Submit" class="farCare-btn save-and-submit" ></a>'.html_safe
		when "continue"
			'<input type="button" value="Save & Continue" class="farCare-btn save-continue first-btn" >
			<button type="button" value="Check-out" class="farCare-btn '.html_safe+ cls +' inactive" >Check-out</button>
			<input type="button" value="Get Signature" class="farCare-btn get-signature inactive" >'.html_safe
		end
	end

	def check_in_active? (event,app)
		if app == "web"
			if (event.event_current_day? and current_user.care_giver.checked_out_completely?)
				link_to "Check-in", pcg_edit_my_services_path(params[:id]), class: "farCare-btn check-in-button  first-btn m_btm-15"
			else
				'<input type="button" value="Check-in" class="farCare-btn check-in-button  first-btn m_btm-15 inactive not_checkedout">'.html_safe
			end
		elsif app == "mobile"
			# link_to (button_tag "Check-in",:type => 'button',:class => "farCare-btn check-out  first-btn m_btm-15"),mobile_view_care_client_services_path(@assigned_event)
			unless event.status.eql?("closed")
				link_to "Continue", mobile_view_care_client_services_path(params[:id]), class: "farCare-btn first-btn continue m_btm-15"
			else
				if(event.event_current_day? and event.status.eql?("closed") and current_user.care_giver.checked_out_completely?)
					link_to "Check-in", mobile_view_care_client_services_path(params[:id]), class: "farCare-btn check-in  first-btn m_btm-15"
				else
					link_to "Check-in", "#", class: "farCare-btn check-in  first-btn m_btm-15 inactive not_checkedout"
				end
			end
		end
	end

	# generating links for un checked out assigned event check out
	def link_for_checking_out app
		if app == "web"
			link_to 'Click here', '/pcg/edit_my_services/'+ @unchecked_assigned_event_id.to_s , :target => '_blank'
		elsif app == "mobile"
			link_to "Click here", "/mobile/home/#{@unchecked_assigned_event_id}/view_care_client_services", :target => "_blank"
		end
	end

	def checkin_inactive_msg app
		if !@event.event_checkin_pass?
			"Check-in can be done only from 1 hour prior to the appointment and on the Same day"
		elsif !current_user.care_giver.checked_out_completely?
			"You have an appointment that is not checked out currently. Please 
           #{ link_for_checking_out app } to check out.".html_safe
		end
	end

	def colour_event event
		event.color
	end
	
	def mr_code_name?(care_client)
		if care_client.is_private_record?
			link_to care_client.medical_record_number, "#", id: "farCare-popup-#{care_client.id}", class: "mr_popup"
		else
			link_to get_full_name(care_client), mobile_care_client_detail_path(care_client.id)
		end
	end

	def checkout_time(assigned_event)
		if @assigned_event.checked_out_at 
			'Checked out at: <b>'.html_safe + (assigned_event.checked_out_at.to_datetime.convert_to(time_zone).strftime("%m/%d/%Y %H:%M:%S %p") ).to_s
		else
			'Expected End Time: <b>'.html_safe + (assigned_event.cc_event.endtime.to_datetime.strftime("%m/%d/%Y %H:%M:%S %p") ).to_s
		end
	end

	def mobile_checkout_time(assigned_event)
		if assigned_event.checked_out_at
			'<label>Check-out time:</label> <span>'.html_safe + (assigned_event.checked_out_at.to_datetime.convert_to(time_zone).strftime("%m/%d/%Y %H:%M:%S %p")).to_s + '</span>'.html_safe
		else
			'<label>Expected End Time:</label> <span>'.html_safe + (assigned_event.cc_event.endtime.to_datetime.strftime("%m/%d/%Y %H:%M:%S %p") ).to_s + '</span>'.html_safe
		end
	end

	def event_status(status)
		if status
			'('+ status + ')'
		else
			""
		end
	end

end
