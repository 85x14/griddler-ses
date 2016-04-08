# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'griddler/ses/version'

Gem::Specification.new do |spec|
  spec.name          = "griddler-ses"
  spec.version       = Griddler::Ses::VERSION
  spec.authors       = ["Kent Mewhort @ Coupa"]
  spec.email         = ["kent.mewhort@coupa.com"]

  spec.summary       = %q{Griddler adapter for AWS SES (handle incoming email replies through SES)}
  spec.homepage      = "https://github.com/coupa/griddler-ses"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'griddler'
  spec.add_runtime_dependency 'mail'
  spec.add_runtime_dependency 'sns_endpoint'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
