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
    ensure_worker_running
    QUEUE << payload
  end

  def self.ensure_worker_running
    return if worker_running?
    LOCK.synchronize do
      return if worker_running?
      start_worker
    end
  end

  def self.worker_running?
    @worker_thread and @worker_thread.alive?
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
    raise Mettric::CouldNotStartWorkerThread, exception unless @worker_thread.alive?
  end
end

