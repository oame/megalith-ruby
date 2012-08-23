# -*- encoding: utf-8 -*-
require File.expand_path('../lib/megalith/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Oame"]
  gem.email         = ["oame@oameya.com"]
  gem.description   = %q{Megalith Parser for Ruby 1.9.x.}
  gem.summary       = %q{Megalith Parser for Ruby}
  gem.homepage      = "https://github.com/oame/megalith-ruby"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "megalith"
  gem.require_paths = ["lib"]
  gem.version       = Megalith::VERSION
end
