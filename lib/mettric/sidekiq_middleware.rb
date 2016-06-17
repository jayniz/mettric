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
    begin
      opts = worker.class.sidekiq_options['mettric']

      # Don't do anything if we're told to skip this class
      if opts != true and opts != nil
        return yield
      end

      # Tracking under this name
      service = "sidekiq.queue:#{queue.to_s.underscore}.worker:#{worker.class.name.underscore}"

      # Yield & time
      Mettric.time(service: "#{service}.duration", tags: ['sidekiq']) do
        yield
      end
    rescue
      Mettric.event(service: "#{service}.error", tags: ['sidekiq'])
      raise
    end

    # Track success
    Mettric.event(service: "#{service}.success", tags: ['sidekiq'])
  end
rescue => e
  raise unless e.is_a?(Mettric::Error)
end

