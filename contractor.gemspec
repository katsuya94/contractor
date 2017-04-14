# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'contractor/version'

Gem::Specification.new do |spec|
  spec.name          = "contractor"
  spec.version       = Contractor::VERSION
  spec.authors       = ["Adrien Katsuya Tateno"]
  spec.email         = ["adrien.k.tateno@gmail.com"]

  spec.summary       = %q{Contractor holds your methods accountable.}
  spec.homepage      = "https://github.com/katsuya94/contractor"

  spec.files         = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r{^lib/})
  end
  spec.bindir        = "bin"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "method_decorators", "~> 0.9.6"
end
