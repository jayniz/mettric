require 'active_support/inflector'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'
require 'riemann/client'

class Mettric::Client
  attr_reader :app, :host

  def initialize(config = ::Mettric.config)
    @config = config || {}
    @riemann = Riemann::Client.new(
      host:    @config[:host]    || 'localhost',
      port:    @config[:port]    || 5555,
      timeout: @config[:timeout] || 5
    )

    self.app  = (@config[:app] || rails_app_name).to_s.underscore
    self.host = (@config[:reporting_host] || host_name).to_s.underscore


    if block_given?
      begin
        yield self
      ensure
        close
      end
    end
  end

  def app=(app_name)
    raise Mettric::MissingAppName, app.inspect if app_name.blank?
    @app = app_name
  end

  def host=(host_name)
    raise Mettric::MissingHostName if host_name.blank?
    @host = host_name
  end

  def <<(payload)
    @riemann.tcp << standardize_payload(payload)
  rescue => e
    @riemann.tcp << { service: 'Mettric error', description: e.to_s }
  end

  def [](*args)
    @riemann[*args]
  end

  def close
    @riemann.close
  end

  def connected?
    @riemann.connected?
  end

  private

  def standardize_payload(payload)
    out = payload.symbolize_keys
    raise Mettric::MissingService, out if out[:service].blank?
    out[:tags] ||= []
    out[:tags] << 'mettric'
    out[:host] = host
    out[:service] = "#{app}.#{out[:service]}"
    out
  end

  def rails_app_name
    return unless Kernel.const_defined?(:Rails)
    Rails.application.class.parent.to_s.underscore
  end

  def host_name
    (ENV['METTRIC_REPORTING_HOST'] || `hostname`).to_s.chomp.underscore
  end
end
