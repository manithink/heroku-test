class VacationManagementMailer < ActionMailer::Base
  # include Sidekiq::Worker
  default from: "mail.homacare@gmail.com"

  def send_pcg_request(vacation_id)
  	@vacation = VacationManagement.find(vacation_id)
  	@pcga = @vacation.care_giver.care_giver_company
  	@pcg = @vacation.care_giver
  	attachments.inline['logo.png'] = image(@pcga.admin_email)
  	mail(to: @pcga.admin_email, cc: @pcg.user.email, subject: "Vacation Request from #{@pcg.first_name} #{@pcg.last_name}")
  end

  def send_vacation_status(vacation_id)
  	@vacation =  VacationManagement.find(vacation_id)
  	@pcga = @vacation.care_giver.care_giver_company
  	@pcg = @vacation.care_giver
  	attachments.inline['logo.png'] = image(@pcga.admin_email)
  	mail(to: @pcg.user.email, cc: @pcga.admin_email, subject: "Vacation Request from #{@pcg.first_name} #{@pcg.last_name}")
  end

  def image admin_email
    admin_setting = @pcg.care_giver_company.admin_setting
    logo = Image.where("id in(?)",admin_setting.image_ids).last
    unless logo.nil?
      return  File.read(Rails.root.to_s + "/public/#{logo.image}") rescue nil
    else
      return File.read(Rails.root.to_s + "/app/assets/images/login-logo.png")
    end
  end

end
