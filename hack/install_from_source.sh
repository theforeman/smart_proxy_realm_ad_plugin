#!/bin/bash

# Not intended to be run as a script, but rather as a guide to install smart_proxy_realm_ad_plugin from source code.
# This script demonstrates how to install smart_proxy_realm_ad_plugin from source code.
docker run -it ubuntu:22.04

# Setup the environment
apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libssl-dev \
    pkg-config \
    sudo \
    wget \
    jq

# Install ruby-install
wget https://github.com/postmodern/ruby-install/releases/download/v0.9.3/ruby-install-0.9.3.tar.gz
tar -xzvf ruby-install-0.9.3.tar.gz
cd ruby-install-0.9.3/
make install

# Install Ruby
ruby-install 3.3.4

# Add Ruby to the PATH
export PATH=/usr/local/src/ruby-3.3.4:/usr/local/src/ruby-3.3.4/bin:/opt/rubies/ruby-3.3.4/bin:$PATH
ruby -v

# Clone smart-proxy into ~/smart-proxy
cd ~
git clone https://github.com/theforeman/smart-proxy.git
git clone https://github.com/theforeman/smart_proxy_realm_ad_plugin.git 

# Install the smart_proxy_realm_ad_plugin from source code
cd smart_proxy_realm_ad_plugin

# Install the dependencies
apt-get -y install libkrb5-dev libldap-dev ruby-dev libsasl2-dev
bundle install
gem build smart_proxy_realm_ad_plugin.gemspec
gem list|grep radcli

# Build the gem
gem build smart_proxy_realm_ad_plugin.gemspec
gem install smart_proxy_realm_ad_plugin-0.0.1.gem

cd ~/smart-proxy

# Install native dependencies for smart-proxy
apt-get install -y ruby-libvirt libvirt-dev libsystemd-dev apt-get

# Install the dependencies for the smart-proxy
bundle install

# smart-proxy find plugins using the bundler.d/Gemfile.local.rb file.
#
echo "gem 'smart_proxy_realm_ad_plugin', :path => '~/smart_proxy_realm_ad_plugin'" >> ./bundler.d/Gemfile.local.rb

# Enable the plugin in the smart-proxy. 
cd ~/smart-proxy

# Its a realm plugin, so we need to enable the realm plugin:
rm -f ~/smart-proxy/config/settings.d/realm.yml

cat > ~/smart-proxy/config/settings.d/realm.yml <<EOF
---
# Can be true, false, or http/https to enable just one of the protocols
:enabled: true

# Available providers:
#   realm_freeipa
:use_provider: realm_ad
EOF

# We need to create a keytab file for the plugin to work. 
mkdir -p /etc/foreman-proxy
touch /etc/foreman-proxy/realm_ad.keytab

# The plugin requires some configuration to work, this is done in the realm_ad.yml file
rm -f ~/smart-proxy/config/settings.d/realm_ad.yml
cat > ~/smart-proxy/config/settings.d/realm_ad.yml <<EOF
---
# Authentication for Kerberos-based Realms
:realm: EXAMPLE.COM

# Kerberos pricipal used to authenticate against Active Directory
:principal: realm-proxy@EXAMPLE.COM

# Path to the keytab used to authenticate against Active Directory
:keytab_path:  /etc/foreman-proxy/realm_ad.keytab

# FQDN of the Domain Controller
:domain_controller: dc.example.com

# Optional: OU where the machine account shall be placed
#:ou: OU=Linux,OU=Servers,DC=example,DC=com

# Optional: Prefix for the computername
:computername_prefix: 'my_required_for_now_nice_prefix'

# Optional: Generate the computername by calculating the SHA256 hexdigest of the hostname
#:computername_hash: false

# Optional:  use the fqdn of the host to generate the computername
#:computername_use_fqdn: false
EOF

cat > ~/smart-proxy/config/settings.yml <<EOF
:bind_host: ['*']
:http_port: 8000
:log_file: /tmp/proxy.log
:log_level: DEBUG
EOF

# We can now start the smart-proxy using, bundle exec,
cd ~/smart-proxy
rm -f /tmp/proxy.log|touch /tmp/proxy.log
bundle exec bin/smart-proxy &
cat /tmp/proxy.log

root@40f20ed4b158:~/smart-proxy# cat /tmp/proxy.log

# 2024-08-22T21:47:55  [W] Couldn't find settings file /root/smart-proxy/config/settings.d/facts.yml. Using default settings.
# 2024-08-22T21:47:55  [W] Couldn't find settings file /root/smart-proxy/config/settings.d/dns.yml. Using default settings.
# 2024-08-22T21:47:55  [W] Couldn't find settings file /root/smart-proxy/config/settings.d/templates.yml. Using default settings.
# 2024-08-22T21:47:55  [W] Couldn't find settings file /root/smart-proxy/config/settings.d/tftp.yml. Using default settings.
# 2024-08-22T21:47:55  [W] Couldn't find settings file /root/smart-proxy/config/settings.d/dhcp.yml. Using default settings.
# 2024-08-22T21:47:55  [W] Couldn't find settings file /root/smart-proxy/config/settings.d/puppetca.yml. Using default settings.
# 2024-08-22T21:47:55  [W] Couldn't find settings file /root/smart-proxy/config/settings.d/puppet.yml. Using default settings.
# 2024-08-22T21:47:55  [W] Couldn't find settings file /root/smart-proxy/config/settings.d/bmc.yml. Using default settings.
# 2024-08-22T21:47:55  [D] 'realm' settings: 'enabled': true, 'use_provider': realm_ad
# 2024-08-22T21:47:55  [D] 'realm' ports: 'http': true, 'https': true
# 2024-08-22T21:47:55  [W] Couldn't find settings file /root/smart-proxy/config/settings.d/logs.yml. Using default settings.
# 2024-08-22T21:47:55  [D] 'logs' settings: 'enabled': true (default)
# 2024-08-22T21:47:55  [D] 'logs' ports: 'http': true, 'https': true
# 2024-08-22T21:47:55  [W] Couldn't find settings file /root/smart-proxy/config/settings.d/httpboot.yml. Using default settings.
# 2024-08-22T21:47:55  [W] Couldn't find settings file /root/smart-proxy/config/settings.d/registration.yml. Using default settings.
# 2024-08-22T21:47:55  [D] Providers ['realm_ad'] are going to be configured for 'realm'
# 2024-08-22T21:47:55  [D] 'realm_ad' settings: 'computername_prefix': my_required_for_now_nice_prefix, 'computername_use_fqdn': false (default), 'domain_controller': dc.example.com, 'keytab_path': /etc/foreman-proxy/realm_ad.keytab, 'principal': realm-proxy@EXAMPLE.COM, 'realm': EXAMPLE.COM, 'use_provider': realm_ad
# 2024-08-22T21:47:55  [I] Successfully initialized 'foreman_proxy'
# 2024-08-22T21:47:55  [I] Successfully initialized 'realm_ad'
# 2024-08-22T21:47:55  [I] Successfully initialized 'realm'
# 2024-08-22T21:47:55  [D] Log buffer API initialized, available capacity: 2000/1000
# 2024-08-22T21:47:55  [I] Successfully initialized 'logs'
# 2024-08-22T21:47:55  [W] Missing SSL setup, https is disabled.
# 2024-08-22T21:47:55  [I] Smart proxy has launched on 1 socket(s), waiting for requests

# Verify that plugins runs...

curl -s -H "Accept: application/json" http://localhost:8000/features|jq

# create host
curl -s -d 'hostname=server1.example.com' http://localhost:8000/realm/EXAMPLE.COM|jq
curl -d 'hostname=server1.example.com&rebuild=true' http://localhost:8000/realm/EXAMPLE.COM
curl -XDELETE http://localhost:8000/realm/EXAMPLE.COM/server1

# We can find log messages grepping the smart_proxy log file
cat /tmp/proxy.log |grep realm_ad
