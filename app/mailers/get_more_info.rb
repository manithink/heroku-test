class GetMoreInfo < ActionMailer::Base
  default from: "maniblacky006@gmail.com"
    def sent_info(params)
    @name = params[:name]
    @email = params[:email]
    attachments.inline['logo.png'] = File.read(Rails.root.to_s + "/app/assets/images/login-logo.png")
    delivery_options = { user_name: 'maniblacky006@gmail.com',
                         password: 'Viswanathaan6',
                         address: "smtp.gmail.com" }
   # mail(to: "cyril@qburst.com", subject: 'Guest User Info', delivery_method_options: delivery_options)
   mail(to: "subramanian@thinkbridge.in", subject: 'Guest User Info', delivery_method_options: delivery_options)


  end
end
