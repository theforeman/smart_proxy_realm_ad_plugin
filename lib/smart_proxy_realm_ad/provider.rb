require 'proxy/kerberos'
require 'radcli'

module Proxy::AdRealm
    class Provider
        include Proxy::Log
        include Proxy::Util
        include Proxy::Kerberos

        def initialize(realm, keytab_path, principal, domain_controller)
            @realm = realm
            @keytab_path = keytab_path
            @principal = principal
            @domain_controller = domain_controller
            @domain = realm.downcase
        end

        def check_realm realm
            raise Exception.new "Unknown realm #{realm}" unless realm.casecmp(@realm).zero?
        end

        def find hostname
            true
        end

        def create realm, hostname, params
        end

        def delete realm, hostname
        end

        private

        def hostfqdn_hostname host_fqdn
        end

        def do_host_create hostname, password
        end

        def do_host_rebuild hostname, password
        end

        def kinit_racdli_connect
        end

        def radcli_connect
        end

        def radcli_join
        end

        def generate_password
        end

        def racli_password
        end

        def radcli_delete
        end

    end
end
