require 'active_support/inflector'

class Mettric::SidekiqMiddleware

  def self.install
    return if @installed
    return unless Kernel.const_defined?(:Sidekiq)
    @installed = true
    Sidekiq.configure_server do |config|
      config.server_middleware do |chain|
        chain.add Mettric::SidekiqMiddleware
      end
    end
  end

  def initialize(_options = {})
  end

  def call(worker, msg, queue)
    opts = worker.class.sidekiq_options['mettric']

    # Don't do anything if we're told to skip this class
    if opts != true and opts != nil
      return yield
    end

    # Tracking under this name
    service = "sidekiq.#{queue.to_s.underscore}.#{worker.class.name.underscore}"

    # Yield & time
    Mettric.time(service: "#{service}.duration", tags: ['sidekiq']) do
      yield
    end

    # Track success
    Mettric.event(service: "#{service}.success", tags: ['sidekiq'])
  rescue => e
    Mettric.event(service: "#{service}.failure", tags: ['sidekiq', 'error'], description: e.to_s)
    raise unless e < Mettric::Error
  end
end

