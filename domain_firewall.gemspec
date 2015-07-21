# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'domain_firewall/version'

Gem::Specification.new do |spec|
  spec.name          = "domain_firewall"
  spec.version       = DomainFirewall::VERSION
  spec.authors       = ["Dave Vallance", "Jeremy Baker"]
  spec.email         = ["davevallance@gmail.com", "jhubert@gmail.com"]

  spec.summary       = %q{Rack middleware for whitelisting IP addresses}
  spec.description   = %q{Rack middleware for whitelisting IP addresses. Allows you to define a custom whitelist per domain.}
  spec.homepage      = "https://github.com/retailzipline/domain_firewall"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
