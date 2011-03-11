# -*- mode:ruby ; encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "faster_open_struct/version"

Gem::Specification.new do |s|
  s.name        = "faster_open_struct"
  s.version     = Faster::OpenStruct::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Evgeniy Dolzhenko"]
  s.email       = ["dolzenko@gmail.com"]
  s.homepage    = "https://github.com/dolzenko/faster_open_struct"
  s.summary     = %q{Up to 40 (!) times more memory efficient version of OpenStruct}
  s.description = %q{Up to 40 (!) times more memory efficient version of OpenStruct}

  #s.rubyforge_project = "faster_open_struct"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
