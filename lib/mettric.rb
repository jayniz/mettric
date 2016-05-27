require 'bundler'
Bundler.require

require 'mettric/version'
require 'mettric/mettric'

class Mettric
  include Mettric

  class << self
    attr_accessor :config
  end
end

def ⚡️
  Mettric
end
