# SCNR
def 🌡(payload)
  Mettric.track(payload)
end

def ⏱(payload, &block)
  Mettric.time(payload) do
    block.call
  end
end

