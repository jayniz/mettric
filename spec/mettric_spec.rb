require 'spec_helper'

describe Mettric do
  context 'worker thread' do
    it "doesn't mind if there is no mettric configured" do
      expect{
        🌡 service: 'My Service', metric: 22.02
      }.to_not raise_error
    end

    xit 'starts a worker only once' do
      Mettric.config = {
        poll_intervall: 300,
        app: :test_app,
        host: :test_host
      }

      expect(Mettric).to receive(:start_worker).exactly(1)

      # 31 times because mettric emits an event of its own start
      allow_any_instance_of(Mettric::Worker).to receive(:deliver)
      30.times do
        🌡 service: 'My Service', metric: 22.02
      end
    end

    it 'tracks in the background' do
      Mettric.config = {
        poll_intervall: 300,
        app: :test_app,
        host: :test_host
      }

      expect_any_instance_of(Mettric::Worker).to receive(:deliver).at_least(30)
      30.times do
        🌡 service: 'My Service', metric: 22.02
      end

      # Wait for background thread to do its work
      sleep 0.1
    end
  end
end

