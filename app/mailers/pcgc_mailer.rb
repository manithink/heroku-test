class PcgcMailer < ActionMailer::Base
  def pcgc_confirmation(user)
  	@user = user
    mail(:to => @user.email, :subject => "Registered", :from => "homacare.adm@gmail.com")
  end
end
