require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
require 'mina/rvm'    # for rvm support. (http://rvm.io)
require 'mina_sidekiq/tasks'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, '54.86.165.53'
set :deploy_to, '/home/devuser/farcare'
set :repository, 'https://sajeerjaleel@bitbucket.org/qburstfarcare/farcare.git'
set :branch, 'release'
set :term_mode, nil
# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'log','public/uploads','public/signatures']

# Optional settings:
  set :user, 'devuser'    # Username in the server to SSH to.
  set :port, '2112'     # SSH port number.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use[ruby-2.1.0@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue  %[echo "-----> Be sure to edit 'shared/config/database.yml'."]

  queue! %[mkdir "#{deploy_to}/shared/public"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public"]

  queue! %[mkdir "#{deploy_to}/shared/public/uploads"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/uploads"]

  queue! %[mkdir "#{deploy_to}/shared/public/signatures"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/signatures"]
end

task :seed => :environment do
  queue "bundle exec rake db:seed"
end

# task :truncate => :environment do
#   queue "bundle exec rake db:truncate"
# end

task :rails_console => :environment do
  queue "rails c"
end

task :stop_server => :environment do
  queue! %[sudo pkill nginx]
  queue  %[echo "server stopped!, service will restart automatically..."]
end


desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'sidekiq:quiet'
    invoke :'stop_server'
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    # invoke :'truncate'
    # invoke :'seed'
    invoke :'rails:assets_precompile'

    to :launch do
      queue "touch #{deploy_to}/tmp/restart.txt"
      queue! %[sudo /opt/nginx/sbin/nginx]
      invoke :'sidekiq:restart'
    end
  end
end

task :logs do
  queue 'echo "Contents of the log file are as follows:"'
  queue "tail -f /home/devuser/farcare/shared/log/production.log"
end


task :sidekiq_logs do
  queue 'echo "Contents of the log file are as follows:"'
  queue "tail -f /home/devuser/farcare/current/log/sidekiq.log"
end



# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers