require 'active_support/inflector'

class Mettric::SidekiqMiddleware
  def initialize(_options = {})
  end

  def call(worker, msg, queue)
    opts = worker.class.sidekiq_options['mettric']

    # Don't do anything if we're told to skip this class
    if opts != true and opts != nil
      return yield
    end

    # Track the job timing
    service = "sidekiq.queue.#{queue}.workers.#{worker.class.name.underscore}",
    Mettric.time(service: service, tags: ['sidekiq']) do
      yield
    end
  end
end

if Kernel.const_defined?(:Sidekiq)
  Sidekiq.configure_server do |config|
    config.server_middleware do |chain|
      chain.add Mettric::SidekiqMiddleware
    end
  end
end

