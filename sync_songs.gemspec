# -*- coding: utf-8; mode: ruby -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sync_songs/version'

Gem::Specification.new do |gem|
  gem.name          = 'sync_songs'
  gem.version       = SyncSongs::VERSION
  gem.authors       = ['Sleft']
  gem.email         = ['fte08eas@student.lu.se']
  gem.description   = 'Sync sets of songs'
  gem.summary       = 'SyncSongs'
  gem.homepage      = ''

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.add_runtime_dependency 'grooveshark', ['>=0.2.7']
  gem.add_runtime_dependency 'highline'
  gem.add_runtime_dependency 'lastfm', ['>=1.14.0']
  gem.add_runtime_dependency 'launchy', ['>=2.1.2']
  gem.add_runtime_dependency 'thor', ['>=0.17.0']
end
