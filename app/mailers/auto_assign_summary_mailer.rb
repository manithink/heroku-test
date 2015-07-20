class AutoAssignSummaryMailer < ActionMailer::Base
  default from: "mail.homacare@gmail.com"
    def send_summary(summary, admin_email)
    @summary = summary
    attachments.inline['logo.png'] = image(admin_email)
    delivery_options = { user_name: 'mail.homacare@gmail.com',
                         password: 'homacare@123',
                         address: "smtp.gmail.com" }
   mail(to: admin_email, subject: 'Auto Schedule Summary', delivery_method_options: delivery_options)
  end

  def image admin_email
    current_user = User.find_by_email admin_email
    admin_setting = current_user.care_giver_company.admin_setting
    logo = Image.where("id in(?)",admin_setting.image_ids).last
    unless logo.nil?
      return  File.read(Rails.root.to_s + "/public/#{logo.image}") rescue nil
    else
      return File.read(Rails.root.to_s + "/app/assets/images/login-logo.png")
    end
  end

end
