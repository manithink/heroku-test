module MailerMacros
  
  #id of last email sent
  def last_email
    ActionMailer::Base.deliveries.last
  end

  #reset the email delivery array
  def reset_email
    ActionMailer::Base.deliveries = []
  end
end