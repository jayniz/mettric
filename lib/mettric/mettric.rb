class Mettric
  QUEUE = Queue.new
  LOCK = Mutex.new

  def self.config
    @config
  end

  def self.config=(config)
    config_test = Client.new(config)
    config_test.close
    @config = config
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
    state = 'success'
    start = Time.now
    begin
      yield
    rescue => e
      exception = e
      state = 'failure'
    end
    payload[:metric] = ((Time.now - start) * 1000).to_i
    payload[:description] = [payload[:description], "(ms)"].compact.join(' ')
    payload[:tags] ||= []
    payload[:tags] << :timing
    track(payload)
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

