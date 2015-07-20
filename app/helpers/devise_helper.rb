module DeviseHelper
  
  # Devise error display on devise pages.
  def devise_error_messages!
    return "" if resource.errors.empty?
    error_array = resource.errors.full_messages.uniq
    error_array.delete("Password confirmation should match confirmation")
    messages = error_array.map { |msg| content_tag(:p, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)

    html = <<-HTML
    <div id="error_explanation">
      <p>#{messages}</p>
    </div>
    HTML

    html.html_safe
  end

  #Check for Error messages from Devise
  def devise_error_messages?
    resource.errors.empty? ? false : true
  end

end