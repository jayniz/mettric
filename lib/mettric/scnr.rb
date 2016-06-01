# SCNR
def 🌡(payload)
  Mettric.track(payload)
rescue Mettric::CouldNotStartWorkerThread
  puts "***WARNING***  Mettric::CouldNotStartWorkerThread raised"
end

def ⏱(payload, &block)
  Mettric.time(payload) do
    block.call
  end
rescue Mettric::CouldNotStartWorkerThread
  puts "***WARNING***  Mettric::CouldNotStartWorkerThread raised"
end

