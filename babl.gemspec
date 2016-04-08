# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'babl'

Gem::Specification.new do |spec|
  spec.name          = "babl"
  spec.version       = "0.3.10"
  spec.authors       = ["Lars Kluge"]
  spec.email         = ["l@larskluge.com"]

  spec.summary       = %q{Access the Babl network}
  spec.description   = %q{Access the Babl network}
  spec.homepage      = "https://github.com/babl-sh/ruby-babl"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) } + %w(bin/babl-rpc_darwin_amd64 bin/babl-rpc_linux_amd64)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "quartz", "~> 0.3"
  spec.add_dependency "multi_json", "~> 1.11"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
