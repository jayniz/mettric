require 'spec_helper'

describe Mettric::SidekiqMiddleware do
  class NullWorker
    def self.sidekiq_options
      {}
    end
  end
  class SkipWorker
    def self.sidekiq_options
      { 'mettric' => :skip }
    end
  end
  class FalseWorker
    def self.sidekiq_options
      { 'mettric' => false }
    end
  end
  class TrueWorker
    def self.sidekiq_options
      { 'mettric' => true}
    end
  end

  context 'checking the mettric sidekiq option' do

    it 'null' do
      expect(Mettric).to receive(:time)
      Mettric::SidekiqMiddleware.new({}).call(NullWorker.new, :msg, :queue) do
        '¯\_(ツ)_/¯'
      end
    end

    it 'skip' do
      expect(Mettric).to_not receive(:time)
      Mettric::SidekiqMiddleware.new({}).call(SkipWorker.new, :msg, :queue) do
        '¯\_(ツ)_/¯'
      end
    end

    it 'false' do
      expect(Mettric).to_not receive(:time)
      Mettric::SidekiqMiddleware.new({}).call(FalseWorker.new, :msg, :queue) do
        '¯\_(ツ)_/¯'
      end
    end

    it 'true' do
      expected_time = {
        service: 'sidekiq.queue:my_queue.worker:true_worker.duration',
        tags: ['sidekiq']
      }
      expect(Mettric).to receive(:time).with(expected_time)

      expected_event = {
        service: 'sidekiq.queue:my_queue.worker:true_worker.success',
        tags: ['sidekiq']
      }
      expect(Mettric).to receive(:event).with(expected_event)
      Mettric::SidekiqMiddleware.new({}).call(TrueWorker.new, {}, :my_queue) do
        '¯\_(ツ)_/¯'
      end
    end
  end
end
