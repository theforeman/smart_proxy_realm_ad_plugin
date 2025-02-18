1. Create a user EXAMPLE@realm-proxy in the User OU.
2. Set the password and make sure its active.
3. Give this user permission to manage computer accounts in the Computers OU.
4. Create a keytab in the linux machine using ktutil and the account password.
5. Put the keytab in /etc/foreman/

marten@martenubuntu:~/src/smart-proxy$ klist -k -t /etc/foreman-proxy/realm-proxy.keytab 
Keytab name: FILE:/etc/foreman-proxy/realm-proxy.keytab
KVNO Timestamp           Principal
---- ------------------- ------------------------------------------------------
   1 2017-07-31 09:34:13 realm-proxy@EXAMPLE.COM

6. Make sure the settings file for the plugin is correct

marten@martenubuntu:~/src/smart-proxy$ cat ./config/settings.d/realm.yml
---
# Can be true, false, or http/https to enable just one of the protocols
:enabled: true

# Available providers:
#   realm_freeipa
:use_provider: realm_ad

# Authentication for Kerberos-based Realms
:realm: EXAMPLE.COM

:keytab_path:  /etc/foreman-proxy/realm-proxy.keytab
:principal: realm-proxy@EXAMPLE.COM

:domain_controller: dc.example.com

marten@martenubuntu:~/src/smart-proxy$


apt-get install adcli
adcli info --domain=EXAMPLE.COM --domain-controller=dc.example.com

