# An event (to become a rate)
# https://youtu.be/pWso-qRaIlM?t=48
def 🛎 (payload)
  Mettric.event(payload)
rescue Mettric::CouldNotStartWorkerThread
  puts "***WARNING***  Mettric::CouldNotStartWorkerThread raised"
end

# A meter
def 🌡 (payload)
  Mettric.meter(payload)
rescue Mettric::CouldNotStartWorkerThread
  puts "***WARNING***  Mettric::CouldNotStartWorkerThread raised"
end

# A duration
def ⏱ (payload, &block)
  Mettric.time(payload) do
    block.call
  end
rescue Mettric::CouldNotStartWorkerThread
  puts "***WARNING***  Mettric::CouldNotStartWorkerThread raised"
end

