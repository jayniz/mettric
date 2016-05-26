require 'active_support/inflector'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'
require 'riemann/client'

class Mettric
  class MissingAppName < StandardError; end
  class MissingHostName < StandardError; end

  module Mettric

    attr_reader :app, :host

    def initialize(config = ::Mettric.config)
      @config = config || {}
      @riemann = Riemann::Client.new(
        host:    @config[:host]    || 'localhost',
        port:    @config[:port]    || 5555,
        timeout: @config[:timeout] || 5
      )

      self.app  = (@config[:app] || rails_app_name).to_s.underscore
      self.host = (@config[:host] || host_name).to_s.underscore


      if block_given?
        begin
          yield self
        ensure
          close
        end
      end
    end

    def app=(app_name)
      raise MissingAppName, app.inspect if app_name.blank?
      @app = app_name
    end

    def host=(host_name)
      raise MissingHostName if host_name.blank?
      @host = host_name
    end

    def <<(payload)
      p = payload.with_indifferent_access
      p[:host] = host
      p[:service] = "#{app}.#{p[:service]}"
      @riemann << p.to_hash.symbolize_keys
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

    def rails_app_name
      return unless Kernel.const_defined?(:Rails)
      Rails.application.class.parent.to_s.underscore
    end

    def host_name
      (ENV['METTRIC_REPORTING_HOST'] || `hostname`).to_s.chomp.underscore
    end
  end
end
