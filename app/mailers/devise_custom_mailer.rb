class DeviseCustomMailer < Devise::Mailer

	helper :application

	include Devise::Controllers::UrlHelpers

	# if self.included_modules.include?(AbstractController::Callbacks)
	# 	raise "You've already included AbstractController::Callbacks, remove this line."
	# else
	# 	include AbstractController::Callbacks
	# end
	 
	before_filter :add_inline_attachment!
	 
	def confirmation_instructions(record, token, opts={})
		super
	end
	 
	def reset_password_instructions(record, token, opts={})
		super
	end
	 
	def unlock_instructions(record, token, opts={})
		super
	end
	 
	private
	def add_inline_attachment!
		attachments.inline['header.png']  = File.read(Rails.root.to_s + "/app/assets/images/login-logo.png")
	end
end