require 'spec_helper'

describe Mettric do
  context 'worker thread' do
    it 'tracks in the background' do
      Mettric.config = {
        poll_intervall: 300,
        app: :test_app,
        host: :test_host
      }

      expect_any_instance_of(Mettric::Worker).to receive(:deliver).exactly(30)
      30.times do
        🌡 service: 'My Service', metric: 22.02
      end
      sleep 1
    end
  end
end

