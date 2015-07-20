class InviteFamilyMailer < ActionMailer::Base
  default from: 'mail.homacare@gmail.com'
 
  def invitation_email(emails,comment,url,user,company_name)
    @emails = emails
    @content = comment
    # @url  = 'http://farcare.qburst.com/' + @user.admin_setting.custom_url.to_s
    @url  = 'http://www.homacare.net/' + url
    attachments.inline['logo.png'] = image(company_name)
    @user = user
    delivery_options = { user_name: 'mail.homacare@gmail.com',
                         password: 'homacare@123',
                         address: "smtp.gmail.com" }
    mail(to: @emails, subject: 'Welcome to HomaCare', delivery_method_options: delivery_options)
  end

  def image company_name
    care_giver_company = CareGiverCompany.find_by_company_name company_name
    current_user = care_giver_company.user
    admin_setting = current_user.care_giver_company.admin_setting
    logo = Image.where("id in(?)",admin_setting.image_ids).last
    unless logo.nil?
      return  File.read(Rails.root.to_s + "/public/#{logo.image}") rescue nil
    else
      return File.read(Rails.root.to_s + "/app/assets/images/login-logo.png")
    end
    sss
  end

end
