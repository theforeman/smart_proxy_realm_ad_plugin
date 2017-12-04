require 'proxy/kerberos'
require 'radcli'
require 'passgen'

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
            logger.info "Proxy::AdRealm: initialize... #{@realm}, #{@keytab_path}, #{@principal}, #{@domain_controller}, #{@domain}"
        end

        def check_realm realm
            raise Exception.new "Unknown realm #{realm}" unless realm.casecmp(@realm).zero?
        end

        def find hostfqdn
            true
        end

        def create realm, hostfqdn, params
            logger.info "Proxy::AdRealm: create... #{realm}, #{hostfqdn}, #{params}"
            check_realm realm
            kinit_radcli_connect

            password = generate_password
            result = { :randompassword => password }

            if params[:rebuild] == "true"
              do_host_rebuild hostfqdn, password
            else
              do_host_create hostfqdn, password
            end

            JSON.pretty_generate(result)
        end

        def delete realm, hostfqdn
            logger.info "Proxy::AdRealm: delete... #{realm}, #{hostfqdn}"
            kinit_radcli_connect
            check_realm realm
            radcli_delete hostfqdn
        end

        private

        def hostfqdn_to_hostname host_fqdn
            begin
              host_fqdn_split = host_fqdn.split('.')
              host_fqdn_split[0]
            rescue => e
              logger.debug "hostfqdn_to_hostname error: #{e}"
              raise e
            end
        end

        def do_host_create hostfqdn, password
            hostname = hostfqdn_to_hostname hostfqdn
            radcli_join hostfqdn, hostname, password
        end

        def do_host_rebuild hostfqdn, password
            hostname = hostfqdn_to_hostname hostfqdn
            radcli_password hostname, password

        end

        def kinit_radcli_connect
            init_krb5_ccache @keytab_path, @principal
            @adconn = radcli_connect()
        end

        def radcli_connect
            # Connect to active directory
            conn = Adcli::AdConn.new(@domain)
            conn.set_domain_realm(@realm)
            conn.set_domain_controller(@domain_controller)
            conn.set_login_ccache_name("")
            conn.connect()
            return conn
        end

        def radcli_join hostfqdn, hostname, password
            # Join computer
            enroll = Adcli::AdEnroll.new(@adconn)
            enroll.set_computer_name(hostname)
            enroll.set_host_fqdn(hostfqdn)
            enroll.set_computer_password(password)
            enroll.join()
        end

        def generate_password
            Passgen::generate(:length => 20)
        end

        def radcli_password hostname, password
            # Reset a computer's password
            enroll = Adcli::AdEnroll.new(@adconn)
            enroll.set_computer_name(hostname)
            enroll.set_computer_password(password)
            enroll.password()
        end

        def radcli_delete hostname
            # Delete a computer's account
            enroll = Adcli::AdEnroll.new(@adconn)
            enroll.set_computer_name(hostname)
            enroll.delete()
        end

    end
end
