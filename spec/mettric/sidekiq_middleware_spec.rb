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
      expect(Mettric).to_not receive(:time)
      Mettric::SidekiqMiddleware.new({}).call(NullWorker.new, :msg, :queue) do
        puts :noop
      end
    end

    it 'skip' do
      expect(Mettric).to_not receive(:time)
      Mettric::SidekiqMiddleware.new({}).call(SkipWorker.new, :msg, :queue) do
        puts :noop
      end
    end

    it 'false' do
      expect(Mettric).to_not receive(:time)
      Mettric::SidekiqMiddleware.new({}).call(FalseWorker.new, :msg, :queue) do
        puts :noop
      end
    end

    it 'true' do
      expect(Mettric).to receive(:time)
      Mettric::SidekiqMiddleware.new({}).call(TrueWorker.new, :msg, :queue) do
        puts :noop
      end
    end
  end
end
