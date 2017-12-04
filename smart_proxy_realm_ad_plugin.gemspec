require File.expand_path('../lib/smart_proxy_realm_ad/version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'smart_proxy_realm_ad_plugin'
  s.version     = Proxy::AdRealm::VERSION
  s.date        = Date.today.to_s
  s.license     = 'GPL-3.0'
  s.authors     = ['Mårten Cassel']
  s.email       = ['marten.cassel@gmail.com']
  s.homepage    = 'https://github.com/martencassel/smart_proxy_realm_ad_plugin'

  s.summary     = "A realm ad provider plugin for Foreman's smart proxy"
  s.description = "A realm ad provider plugin for Foreman's smart proxy"

  s.files       = Dir['{config,lib,bundler.d}/**/*'] + ['README.md', 'LICENSE']
  s.test_files  = Dir['test/**/*']

  s.add_development_dependency('rake')
  s.add_development_dependency('mocha')
  s.add_development_dependency('test-unit')
  s.add_dependency('rkerberos')
  s.add_dependency('passgen')
  s.add_dependency('radcli')
end
