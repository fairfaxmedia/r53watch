# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'r53watch/version'

Gem::Specification.new do |spec|
  spec.name          = "r53watch"
  spec.version       = R53Watch::VERSION
  spec.authors       = ["John Slee"]
  spec.email         = ["john.slee@fairfaxmedia.com.au"]

  spec.summary       = %q{Check that your zones are actually delegated to AWS Route53 correctly}
  spec.description   = %q{Check that your zones are actually delegated to AWS Route53 correctly}
  spec.homepage      = "https://github.com/indigoid/r53watch"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "net-dns", "~> 0.8"
  spec.add_runtime_dependency "thor", "~> 0.19"
  spec.add_runtime_dependency "aws-sdk", "~> 2"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
end
