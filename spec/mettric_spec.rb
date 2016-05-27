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

      it 'tracking metrics defaults to tcp' do
        payload = {service: 'test_app.My Service', metric: 12.5, host: `hostname`.chomp, }
        tcp = double(:tcp)
        expect(tcp).to receive(:<<).with(payload)
        expect_any_instance_of(Riemann::Client).to receive(:tcp).and_return(tcp)
        Mettric.new do |mett|
          mett << {service: 'My Service', metric: 12.5}
        end
      end

      context 'delegating other methods' do
        [:[], :close, :connected?].each do |method|
          it "#{method}" do
            expect_any_instance_of(Riemann::Client).to receive(method).at_least(1)
            Mettric.new do |mett|
              mett.send(method)
            end
          end
        end
      end

    end
  end
end
