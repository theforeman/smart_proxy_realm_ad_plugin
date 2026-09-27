# frozen_string_literal: true

require File.expand_path('./lib/smart_proxy_realm_ad/version', __dir__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'smart_proxy_realm_ad_plugin'
  s.version     = Proxy::AdRealm::VERSION
  s.license     = 'GPL-3.0-or-later'
  s.authors     = ['Mårten Cassel']
  s.email       = ['marten.cassel@gmail.com']
  s.homepage    = 'https://github.com/theforeman/smart_proxy_realm_ad_plugin'

  s.summary     = 'Smart Proxy Realm AD Plugin'
  s.description = "A realm Active Directory provider plugin for Foreman's smart proxy"

  s.files       = Dir['{config,lib,bundler.d}/**/*'] + ['README.md', 'LICENSE']
  s.test_files  = Dir['test/**/*']

  s.required_ruby_version = '>= 3.0'

  s.add_development_dependency('mocha', '~> 3.0')
  s.add_development_dependency('rack', '~> 2.2.24')
  s.add_development_dependency('rake', '~> 13.0.0')
  s.add_development_dependency('test-unit', '~> 3.0')
  s.add_dependency('radcli', '~> 1.0')
  s.add_dependency('rkerberos', '~> 0.2.0')
end
