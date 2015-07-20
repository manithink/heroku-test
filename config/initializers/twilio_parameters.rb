twilio_parameter = YAML.load_file("#{Rails.root.to_s}/config/twilio.yml")
BASE_URL = twilio_parameter[Rails.env]['base_url']
TWILIO_TOKEN = twilio_parameter[Rails.env]['token']
TWILIO_SID = twilio_parameter[Rails.env]['sid']
TWILIO_PHONE = twilio_parameter[Rails.env]['phone_number']
