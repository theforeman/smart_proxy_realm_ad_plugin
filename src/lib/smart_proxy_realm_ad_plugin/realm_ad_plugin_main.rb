require 'proxy/kerberos'
require 'radcli'

module Proxy::ADRealm
    class Provider
        include Proxy::Log
        include Proxy::Util
        include Proxy::Kerberos
    
        def initialize(realm, keytab_path, principal, domain_controller)
        end

        def check_realm realm
        end

        def find hostname
            true
        end

        def create realm, hostname, params
        end

        def delete realm, hostname
        end

        def generate_password
        end

        private

        def hostfqdn_hostname host_fqdn
            begin
                host_fqdn_split = host_fqdn.split('.')
                host_fqdn_split[0]
            rescue  
                logger.debug "hostfqdn_hostname error"
                raise
            end            
        end

        def do_host_create hostname, password
        end

        def do_host_rebuild hostname, password
        end

        def kinit_radcli_connect
        end

        def radcli_connect
        end

        def radcli_join
        end

        def radcli_password
        end

        def radcli_delete
        end
    end
end