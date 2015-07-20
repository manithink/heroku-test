namespace :db do
  desc "Truncate all tables"
  task :truncate => :environment do
  	conn = ActiveRecord::Base.connection
    tables = %w[users roles users_roles care_giver_companies care_givers countries states package_types company_types organisation_types time_zones images admin_settings]
    tables.each { |t| p conn.execute("TRUNCATE #{t}") }
    Rake::Task["db:seed"].execute
  end
end

namespace :db	do
	desc "Truncare calendar events"
	task :clear_calendar => :environment do
		conn = ActiveRecord::Base.connection
		tables = %w[events event_series assigned_events]
		tables.each { |t| p conn.execute("TRUNCATE #{t}") }
	end
end

namespace :sidekiq do
	desc "Remove all scheduled tasks"
	task :remove_jobs => :environment do
		p "Removing jobs, please wait..."
		AssignedEvent.all.each do |event|
			event.alertreminderjob_ids.each do |id|
				p Sidekiq::Status.cancel id
			end
		end
	end
end