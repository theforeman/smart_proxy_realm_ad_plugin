require 'proxy/kerberos'
require 'radcli'
require 'digest'

module Proxy::AdRealm
  class Provider
    include Proxy::Log
    include Proxy::Util
    include Proxy::Kerberos

    attr_reader :realm, :keytab_path, :principal, :domain_controller, :domain, :ou, :computername_prefix, :computername_hash, :computername_use_fqdn, :ignore_computername_exists

    def initialize(options = {})
      @realm = options[:realm]
      @keytab_path = options[:keytab_path]
      @principal = options[:principal]
      @domain_controller = options[:domain_controller]
      @domain = options[:realm].downcase
      @ou = options[:ou]
      @computername_prefix = options[:computername_prefix]
      @computername_hash = options[:computername_hash]
      @computername_use_fqdn = options[:computername_use_fqdn]
      @ignore_computername_exists = options.fetch(:ignore_computername_exists, false)
      logger.info 'Proxy::AdRealm: initialize...'
    end

    def check_realm(realm)
      raise Exception, "Unknown realm #{realm}" unless realm.casecmp(@realm).zero?
    end

    def find(_hostfqdn)
      true
    end

    def create(realm, hostfqdn, params)
      logger.debug "Proxy::AdRealm: create... #{realm}, #{hostfqdn}, #{params}"
      check_realm(realm)
      kinit_radcli_connect

      password = generate_password
      result = { randompassword: password }

      computername = hostfqdn_to_computername(hostfqdn)

      if params[:rebuild] == 'true'
        radcli_password(computername, password)
      else
        radcli_join(hostfqdn, computername, password)
      end

      JSON.pretty_generate(result)
    end

    def delete(realm, hostfqdn)
      logger.debug "Proxy::AdRealm: delete... #{realm}, #{hostfqdn}"
      kinit_radcli_connect
      check_realm(realm)
      computername = hostfqdn_to_computername(hostfqdn)
      radcli_delete(computername)
    end

    def hostfqdn_to_computername(hostfqdn)
      computername = hostfqdn

      # strip the domain from the host
      computername = computername.split('.').first unless computername_use_fqdn

      # generate the SHA256 hexdigest from the computername
      computername = Digest::SHA256.hexdigest(computername) if computername_hash

      # apply prefix if it has not already been applied
      computername = computername_prefix + computername if apply_computername_prefix?(computername)

      # limit length to 15 characters and upcase the computername
      # see https://support.microsoft.com/en-us/kb/909264
      computername[0, 15].upcase
    end

    def apply_computername_prefix?(computername)
      !computername_prefix.nil? && !computername_prefix.empty? && (computername_hash || !computername[0, computername_prefix.size].casecmp(computername_prefix).zero?)
    end

    def kinit_radcli_connect
      init_krb5_ccache(@keytab_path, @principal)
      @adconn = radcli_connect
    end

    def radcli_connect
      # Connect to active directory
      conn = Adcli::AdConn.new(@domain)
      conn.set_domain_realm(@realm)
      # Directly connect to the domain controller if specified, skip the SRV lookup
      conn.set_domain_controller(@domain_controller) unless @domain_controller.nil?
      conn.set_login_ccache_name('')
      conn.connect
      conn
    end

    MAX_RETRIES = 100
    RETRY_DELAY = 0.3

    def radcli_join(hostfqdn, computername, password)
      enroll = setup_enroll(hostfqdn, computername, password)
      begin
        enroll.join
        logger.info "Successfully joined computer #{computername} with FQDN #{hostfqdn}"
        true
      rescue RuntimeError => ex
        handle_runtime_error(ex, enroll)
      end
    end

    def generate_password
      characters = ('A'..'Z').to_a + ('a'..'z').to_a + (0..9).to_a
      Array.new(20) { characters.sample }.join
    end

    def radcli_password(computername, password)
      # Reset a computer's password
      enroll = Adcli::AdEnroll.new(@adconn)
      enroll.set_computer_name(computername)
      enroll.set_domain_ou(@ou) if @ou
      enroll.set_computer_password(password)
      enroll.password
    end

    def radcli_delete(computername)
      # Delete a computer's account
      enroll = Adcli::AdEnroll.new(@adconn)
      enroll.set_computer_name(computername)
      enroll.set_domain_ou(@ou) if @ou
      enroll.delete
    end

    private

    def setup_enroll(hostfqdn, computername, password)
      enroll = Adcli::AdEnroll.new(@adconn)
      enroll.set_computer_name(computername)
      enroll.set_host_fqdn(hostfqdn)
      enroll.set_domain_ou(@ou) if @ou
      enroll.set_computer_password(password)
      enroll
    end

    def handle_runtime_error(ex, enroll)
      if ex.message =~ /Authentication error/
        retry_authentication_error(enroll)
      elsif ex.message =~ /already exists/
        handle_already_exists_error
      else
        log_error("Failed to join computer: #{ex.message}")
        raise ex
      end
    end

    def retry_authentication_error(enroll)
      MAX_RETRIES.times do |i|
        sleep(RETRY_DELAY)
        begin
          if enroll.respond_to?(:update)
            enroll.update
          else
            enroll.password
          end
          log_info("Successfully updated computer after authentication error")
          return true
        rescue RuntimeError => ex
          if i >= MAX_RETRIES - 1 || ex.message !~ /Authentication error/
            log_error("Failed to update computer after #{MAX_RETRIES} attempts: #{ex.message}")
            raise ex
          end
        end
      end
    end

    def handle_already_exists_error
      if ignore_computername_exists
        log_info("Computer name already exists, but ignoring as per configuration")
        true
      else
        log_error("Computer name already exists and cannot proceed")
        raise "Computer name already exists"
      end
    end

    def log_info(message)
      logger.info "Proxy::AdRealm: #{message}"
    end

    def log_error(message)
      logger.error "Proxy::AdRealm: #{message}"
    end

  end
end
