# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bottled_service/version'

Gem::Specification.new do |spec|
  spec.name          = "bottled_services"
  spec.version       = BottledService::VERSION
  spec.authors       = ["John_Hayes-Reed"]
  spec.email         = ["john.hayes.reed@gmail.com"]

  spec.summary       = %q{A gourmet service object}
  spec.description   = %q{This gem provides Class to be the base for services and a generator to easily create them.}
  spec.homepage      = "https://github.com/John-Hayes-Reed/bottled_services"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "factory_girl"
end
