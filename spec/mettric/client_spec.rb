require 'spec_helper'

describe Mettric::Client do
  it 'has a version number' do
    expect(Mettric::VERSION).not_to be nil
  end

  context 'instance' do
    context 'with incomplete config' do

      it 'missing host' do
        Mettric.config = {app: :test_app}
        expect(Mettric::Client.new.host).to eq `hostname`.chomp.underscore
      end

      it 'missing app' do
        expect{
          Mettric.config = {host: :test_host}
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

      it 'tracking metrics defaults to tcp' do
        expected_payload = {service: 'test_app.My Service', metric: 12.5, host: `hostname`.chomp, tags: ['mettric'] }
        tcp = double(:tcp)
        expect(tcp).to receive(:<<).with(expected_payload)
        expect_any_instance_of(Riemann::Client).to receive(:tcp).and_return(tcp)
        Mettric::Client.new do |mett|
          mett << {service: 'My Service', metric: 12.5}
        end
      end

      context 'delegating other methods' do
        [:[], :close, :connected?].each do |method|
          it "#{method}" do
            expect_any_instance_of(Riemann::Client).to receive(method).at_least(1)
            Mettric::Client.new do |mett|
              mett.send(method)
            end
          end
        end
      end

    end
  end
end
