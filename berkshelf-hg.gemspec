# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'berkshelf/hg/version'

Gem::Specification.new do |spec|
  spec.name          = 'berkshelf-hg'
  spec.version       = Berkshelf::Hg::VERSION
  spec.authors       = [
    'Seth Vargo',
    'Manuel Ryan',
  ]
  spec.email         = [
    'sethvargo@gmail.com',
    'ryan@shamu.ch',
  ]
  spec.summary       = 'Mercurial (hg) support for Berkshelf'
  spec.description   = 'A Berkshelf plugin that adds support for downloading ' \
                       'Chef cookbooks from Mercurial (hg) locations.'
  spec.homepage      = 'https://github.com/berkshelf/berkshelf-hg'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version     = '>= 2.2.0'
  # Runtime dependencies
  spec.add_dependency 'berkshelf', '>= 6.1', '< 8'

  # Development dependencies
  spec.add_development_dependency 'aruba', '~> 0.13'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
