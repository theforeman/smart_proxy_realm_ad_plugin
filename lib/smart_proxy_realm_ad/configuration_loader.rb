module Proxy::AdRealm
    class ConfigurationLoader
        def load_classes
            require 'smart_proxy_realm_ad/provider'
        end

        def load_dependency_injection_wirings(container_instance, settings)
            container_instance.depedency : realm_provider_impl,
                lambda {
                    ::Proxy::AdRealm::Provider.new(
                        settings[:realm],
                        settings[:keytab_path],
                        settings[:principal],
                        settings[:domain_controller]
                    )
                }
        end
    end
end