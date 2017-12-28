require 'smart_proxy_realm_ad/version'

module Proxy::AdRealm
  class Plugin < Proxy::Provider
    load_classes ::Proxy::AdRealm::ConfigurationLoader
    load_dependency_injection_wirings ::Proxy::AdRealm::ConfigurationLoader

    validate_presence :realm, :keytab_path, :principal, :domain_controller

    plugin :realm_ad, ::Proxy::AdRealm::VERSION
  end
end
