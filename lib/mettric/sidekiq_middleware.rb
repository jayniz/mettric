require 'active_support/inflector'

class Mettric::SidekiqMiddleware
  def initialize(_options)
  end

  def call(worker, msg, queue)
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
