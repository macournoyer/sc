# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sc/version"

Gem::Specification.new do |s|
  s.name        = "sc"
  s.version     = Sc::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Marc-Andre Cournoyer"]
  s.email       = ["macournoyer@gmail.com"]
  s.homepage    = ""
  s.summary     = 
  s.description = "If static site generators were vegies, this one would be a pickle."

  s.rubyforge_project = "sc"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency 'tilt',    '= 1.3.2'
  s.add_dependency 'compass', '= 0.11.1'
  s.add_dependency 'rack',    '>= 1.2.3'
end
