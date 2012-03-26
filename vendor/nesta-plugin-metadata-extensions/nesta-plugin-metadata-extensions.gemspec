# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "nesta-plugin-metadata-extensions/version"

Gem::Specification.new do |s|
  s.name        = "nesta-plugin-metadata-extensions"
  s.version     = Nesta::Plugin::Metadata::Extensions::VERSION
  s.authors     = ["Craig Rindt"]
  s.email       = ["crindt@gmail.com"]
  s.homepage    = "http://crindt.heroku.com"
  s.summary     = %q{Some simple extensions to expose and use more metadata in nesta.}
  s.description = %q{Some simple extensions to expose and use more metadata in nesta.}

  s.rubyforge_project = "nesta-plugin-metadata-extensions"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency("nesta", ">= 0.9.11")
  s.add_development_dependency("rake")
end
