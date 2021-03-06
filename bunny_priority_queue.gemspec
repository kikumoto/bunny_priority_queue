# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bunny_priority_queue/version'

Gem::Specification.new do |spec|
  spec.name          = "bunny_priority_queue"
  spec.version       = BunnyPriorityQueue::VERSION
  spec.authors       = ["Takahiro Kikumoto"]
  spec.email         = ["takakiku810@gmail.com"]
  spec.summary       = %q{Priority Queue library using Bunny with RabbitMQ.}
  spec.description   = %q{Priority Queue library using Bunny with RabbitMQ.}
  spec.homepage      = "https://github.com/kikumoto/bunny_priority_queue"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "bunny"
end
