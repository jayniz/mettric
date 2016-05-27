# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mettric/version'

Gem::Specification.new do |spec|
  spec.name          = "mettric"
  spec.version       = Mettric::VERSION
  spec.authors       = ["Jannis Hermanns"]
  spec.email         = ["jannis@moviepilot.com"]

  spec.summary       = %q{Count metrics}
  spec.description   = %q{Mittwoch ist Metttag}
  spec.homepage      = "https://github.com/moviepilot/mettric"
  spec.license       = "All rights reserved"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "riemann-client", "~> 0.2.6"

  spec.add_development_dependency "pry"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "coveralls"
end
