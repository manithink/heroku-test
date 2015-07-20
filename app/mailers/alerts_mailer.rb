class AlertsMailer < ActionMailer::Base
  default from: 'mail.homacare@gmail.com'
 
  def alert_email(email,content,care_giver_id)
    @care_giver = CareGiver.find care_giver_id
    @email = email
    @content = content
    attachments.inline['logo.png'] = image(email)
    delivery_options = { user_name: 'mail.homacare@gmail.com',
                         password: 'homacare@123',
                         address: "smtp.gmail.com" }
    mail(to: @email, subject: 'HomaCare: Alerts/Reminders', delivery_method_options: delivery_options)
  end

  def location_missing(content,email,care_giver_id)
    @care_giver = CareGiver.find care_giver_id
  	@content = content
  	attachments.inline['logo.png'] = image(email)
  	delivery_options = { user_name: 'mail.homacare@gmail.com',
                         password: 'homacare@123',
                         address: "smtp.gmail.com" }
    mail(to: email, subject: 'GPS Location missing', delivery_method_options: delivery_options)
  end

  def image admin_email
    admin_setting = @care_giver.care_giver_company.admin_setting
    logo = Image.where("id in(?)",admin_setting.image_ids).last
    unless logo.nil?
      return  File.read(Rails.root.to_s + "/public/#{logo.image}") rescue nil
    else
      return File.read(Rails.root.to_s + "/app/assets/images/login-logo.png")
    end
  end

end
