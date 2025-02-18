# frozen_string_literal: true

require File.expand_path('../lib/smart_proxy_realm_ad/version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'smart_proxy_realm_ad_plugin'
  s.version     = Proxy::AdRealm::VERSION
  s.date        = Date.today.to_s
  s.license     = 'GPL-3.0-only'
  s.authors     = ['Mårten Cassel']
  s.email       = ['marten.cassel@gmail.com']
  s.homepage    = 'https://github.com/theforeman/smart_proxy_realm_ad_plugin'

  s.summary     = "A realm ad provider plugin for Foreman's smart proxy"
  s.description = "This plugin provides direct Active Directory realm support for Foreman's smart proxy."

  s.files       = Dir['{config,lib,bundler.d}/**/*'] + ['README.md', 'LICENSE']
  s.test_files  = Dir['test/**/*']

  s.add_development_dependency('rake', '~> 13.0')
  s.add_development_dependency('mocha', '~> 2.6')
  s.add_development_dependency('test-unit', '~> 3.6')
  s.add_dependency('rkerberos', '~> 0.1')
  s.add_dependency('radcli', '~> 1.1')
  s.required_ruby_version = '>= 2.7', '< 4'
end
