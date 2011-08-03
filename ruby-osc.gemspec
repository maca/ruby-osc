# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "ruby-osc/version"

Gem::Specification.new do |s|
  s.name        = "ruby-osc"
  s.version     = Osc::VERSION
  s.authors     = ["Macario"]
  s.email       = ["macarui@gmail.com"]
  s.homepage    = "makarius.me"
  s.summary     = %q{Concise OSC Ruby implementation}
  s.description = %q{Concise OSC Ruby implementation}

  s.rubyforge_project = "ruby-osc"

  s.add_development_dependency 'rspec', '>= 2.6.0'
  s.add_development_dependency 'bundler', '>= 1.0' 
  s.add_dependency 'eventmachine', '>= 0.12.8'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

