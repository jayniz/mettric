class Mettric
  QUEUE = Queue.new
  LOCK = Mutex.new

  def self.config
    @config
  end

  def self.config=(config)
    # See if the config is valid
    config_test = Client.new(config)
    config_test.close

    # Set the config
    @config = config

    # Attempt to install sidekiq middleware unless
    # we're told not to
    if config.delete(:sidekiq_middleware) != false
      Mettric::SidekiqMiddleware.install
    end

    @config
  end

  def self.track(payload)
    return false unless @config
    ensure_worker_running
    QUEUE << payload
    QUEUE.size
  end

  # Tracking meter readings is the default
  def self.meter(payload)
    track(payload)
  end

  # To track events
  def self.event(payload)
    payload[:tags] ||= []
    payload[:tags] << :event
    track(payload)
  end

  # To track durations
  def self.time(payload)
    exception = nil
    result = nil
    state = 'success'
    start = Time.now
    begin
      result = yield
    rescue => e
      exception = e
      state = 'failure'
    end

    # Be super conservative, always return the result
    begin
      timing_payload = payload.dup
      timing_payload[:service] = "#{payload[:service]}.duration"
      timing_payload[:metric] = ((Time.now - start) * 1000).to_i
      timing_payload[:description] = [payload[:description], "(ms)"].compact.join(' ')
      timing_payload[:tags] = (payload[:tags] || []) + [:timing]
      track(timing_payload)
    rescue
      result
    end

    if exception
      event(service: "#{payload[:service]}.failure", tags: payload[:tags], description: exception.to_s) rescue nil
      raise exception
    else
      event(service: "#{payload[:service]}.success", tags: payload[:tags]) rescue result
    end
    result
  end

  def self.ensure_worker_running
    return if worker_running?
    LOCK.synchronize do
      return if worker_running?
      start_worker
    end
  end

  def self.worker_running?
    @worker_thread && @worker_thread.alive?
  end

  def self.start_worker
    exception = nil
    worker = Mettric::Worker.new(QUEUE, @config)
    @worker_thread = Thread.new do
      begin
      worker.start
      rescue => e
        exception = e
      end
    end
    sleep 0.5
    return if @worker_thread.alive?
    raise Mettric::CouldNotStartWorkerThread, exception
  end
end

