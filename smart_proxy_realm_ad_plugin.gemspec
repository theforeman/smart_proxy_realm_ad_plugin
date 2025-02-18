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
  s.required_ruby_version = '>= 2.7'

  s.summary     = "A realm ad provider plugin for Foreman's smart proxy"
  s.description = "This plugin provides a realm ad provider for Foreman's smart proxy, allowing integration with Active Directory realms."


  s.files       = Dir['{config,lib,bundler.d}/**/*'] + ['README.md', 'LICENSE']
  s.test_files  = Dir['test/**/*']

  s.add_development_dependency('rake', '~> 13.2')
  s.add_development_dependency('mocha', '~> 2.7')
  s.add_development_dependency('test-unit', '~> 3.6')
  s.add_dependency('rkerberos', '~> 0.1.5')
  s.add_dependency('radcli', '~> 1.1')
end
