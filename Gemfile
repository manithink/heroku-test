source 'http://production.s3.rubygems.org/'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.1'

# Use postgresql as the database for Active Record
gem 'pg'

gem 'mysql2'

# Use SCSS for stylesheets
#gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
#gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
#gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
#gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'tinymce-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# For authentication
gem 'devise'
# For assign role to user
gem 'rolify'
# For authorization
gem "pundit"

# For file upload
gem 'carrierwave'
# For create PDF doc
gem 'prawn'

# For Fast PostreSQL array parsing
gem 'pg_array_parser'
# gem "rmagick", "~> 2.13.1"

  #gem 'simple_form', '~> 3.0.0.rc'
 # gem 'client_side_validations', git: 'git://github.com/bcardarella/client_side_validations.git'
 # gem 'client_side_validations-simple_form', git: 'git://github.com/saveritemedical/client_side_validations-simple_form.git'
gem 'client_side_validations', github: 'DavyJonesLocker/client_side_validations'
gem 'client_side_validations-simple_form', github: 'DavyJonesLocker/client_side_validations-simple_form'
# gem 'simple_form'
# gem 'client_side_validations'
# gem 'client_side_validations-simple_form'

gem 'jquery-turbolinks'
# gem 'client_side_validations-turbolinks'

gem 'honeybadger'

#geolocation
gem "geocoder"



gem "rspec-rails", :group => [:test, :development]
group :test do
  gem "factory_girl_rails"
  gem "capybara"
  gem "guard-rspec"
  gem "database_cleaner", "~> 1.2.0"
  gem "faker"
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

#for prduction mode
group :assets do
   #gem 'sprockets-rails', github: 'rails/sprockets-rails'
   gem 'sprockets-rails'
  gem 'sass-rails',   '~> 4.0.0.beta1'
  gem 'coffee-rails', '~> 4.0.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', platforms: :ruby

  gem 'uglifier', '>= 1.3.0'
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
end

# pagination gem
gem 'kaminari'

 gem 'multi-select-rails', :git => 'https://github.com/shamithc/multi-select-rails.git'
 # gem 'multi-select-rails'
# deployment gem
gem 'mina'
gem 'mina-sidekiq'

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

#for pdf generation
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'

# twilio
gem 'twilio-ruby'
gem 'sidekiq'
gem 'sinatra', require: false
gem 'slim'
gem 'sidekiq-status', "~> 0.4"
gem "airbrake"
