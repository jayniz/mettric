require 'spec_helper'

describe Mettric do
  it 'has a version number' do
    expect(Mettric::VERSION).not_to be nil
  end

  context 'instance' do
    context 'with incomplete config' do

      it 'missing host' do
        Mettric.config = {app: :test_app}
        expect(Mettric.new.host).to eq `hostname`.chomp.underscore
      end

      it 'missing app' do
        Mettric.config = {host: :test_host}
        expect{
          Mettric.new
        }.to raise_error(Mettric::MissingAppName)
      end
    end

    context 'with valid config' do
      before(:each) do
        Mettric.config = {
          app: :test_app,
          host: :test_host
        }
      end

      it 'supports new blocks' do
        payload = {metric: 12.5, host: 'test_host', service: 'test_app.service'}
        expect_any_instance_of(Riemann::Client).to receive(:<<).with(payload)
        Mettric.new do |client|
          client << {service: :service, metric: 12.5}
        end
      end
    end
  end
end
