class Mettric::Worker
  def initialize(queue, config = Mettric.config)
    @queue = queue
    @config = config
    @stop = false
    @started = false
  end

  def start
    return false if @started
    puts "Mettric::Worker#start" if @config[:debug]
    @started = true
    loop
  end

  def loop
    Mettric::Client.new(@config) do |client|
      deliver(client,  service: 'mettric.worker.start', metric: 1) rescue nil
      while payload = @queue.pop
        deliver(client, payload)
      end
    end
    binding.pry
  end

  def stop
    puts "Mettric::Worker#stop" if @config[:debug]
    @started = false
  end

  private

  def deliver(client, payload)
    puts "Mettric::Worker#deliver #{payload}" if @config[:debug]
    client << payload
  end
end
