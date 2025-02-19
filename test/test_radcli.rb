# frozen_string_literal: true

require 'radcli'

# Connect using password
adconn = Adcli::AdConn.new('example.com')
adconn.set_domain_realm('EXAMPLE.COM')
adconn.set_domain_controller('dc.example.com')
adconn.set_login_user('realm-proxy')
adconn.set_user_password('password')
res = adconn.connect

# Connect using kerberos keytab
require 'radcli'
require 'rkerberos'
principal = 'realm-proxy'
keytab='/etc/foreman-proxy/realm-proxy.keytab'
krb5 = Kerberos::Krb5.new
ccache = Kerberos::Krb5::CredentialsCache.new
krb5.get_init_creds_keytab principal, keytab, nil, ccache
adconn = Adcli::AdConn.new('example.com')
adconn.set_domain_realm('EXAMPLE.COM')
adconn.set_domain_controller('dc.example.com')
adconn.set_login_ccache_name('')
res = adconn.connect


# Delete the computer accounts object
enroll = Adcli::AdEnroll.new(adconn)
enroll.set_computer_name('server1')
enroll.delete()

# Create a computer account object
enroll = Adcli::AdEnroll.new(adconn)
enroll.set_computer_name('server1')
enroll.set_host_fqdn('server1.example.com')
enroll.set_computer_password('password')
enroll.join()

# Reset a computer accounts password
adconn.set_domain_controller('dc.example.com')
enroll = Adcli::AdEnroll.new(adconn)
enroll.set_computer_name('server1')
enroll.set_computer_password('newpass')
enroll.password()

# Delete the computer accounts object
enroll = Adcli::AdEnroll.new(adconn)
enroll.set_computer_name('server1')
enroll.delete()


# Create a computer account object in specific OU
enroll = Adcli::AdEnroll.new(adconn)
enroll.set_domain_ou('OU=Computers,OU=Foobar,DC=example,DC=com')
enroll.set_computer_name('server1')
enroll.set_host_fqdn('server1.example.com')
enroll.set_computer_password('password')
enroll.join()
