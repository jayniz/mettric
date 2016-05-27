class Mettric::Worker
  def initialize(queue, config = Mettric.config)
    @queue = queue
    @config = config
    @stop = false
    @started = false
  end

  def start
    return false if @started
    @started = true
    loop
  end

  def loop
    Mettric::Client.new(@config) do |client|
      while payload = @queue.pop
        deliver(client, payload)
      end
    end
  end

  def stop
    @started = false
  end

  private

  def deliver(client, payload)
    client << payload
  end
end
