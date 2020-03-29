# -*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "ruby-osc/version"

Gem::Specification.new do |s|
  s.name        = "ruby-osc"
  s.version     = Osc::VERSION
  s.authors     = ["Macario"]
  s.email       = ["macarui@gmail.com"]
  s.homepage    = "http://makarius.me"
  s.summary     = "Concise OSC Ruby implementation"
  s.description = "Concise OSC Ruby implementation based on EventMachine"
  s.licenses    = ['MIT']

  s.add_development_dependency "rspec", "~> 3.8"
  s.add_development_dependency "bundler", "~> 1.0"
  s.add_dependency "eventmachine", "~> 1.2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
