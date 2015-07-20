class	TestWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :test_worker

  def perform
    e = Event.last
    p e.id
    e.title = "Testing1111"
    e.save(validate: false)
  end
end
