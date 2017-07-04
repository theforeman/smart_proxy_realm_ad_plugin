#!/bin/sh
subscription-manager register 
subscription-manager repos  --enable rhel-7-server-optional-rpms

sudo yum -y install ruby git ruby-devel
sudo gem update --system

gem install bundler
gem install json_pure
gem install rdoc

sudo yum -y install libvirt-devel
gem install ruby-libvirt

sudo yum -y install augeas-devel

# rkerberos
sudo yum -y install byacc
wget http://web.mit.edu/kerberos/dist/krb5/1.14/krb5-1.14.tar.gz
tar -xzf krb5-1.14.tar.gz
cd krb5-1.14/src
export CPPFLAGS='-I/usr/local/opt/openssl/include'
export LDFLAGS='-L/usr/local/opt/openssl/lib'
./configure
make
sudo make install

git clone git://github.com/theforeman/smart-proxy.git
cd smart-proxy
bundle

# Download a sample plugin
# https://github.com/theforeman/smart_proxy_dns_plugin_template

git clone https://github.com/theforeman/smart_proxy_dns_plugin_template \
    smart_proxy_realm_ad_plugin
cd smart_proxy_realm_ad_plugin/

./rename.rb smart_proxy_realm_ad_plugin

# http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Smart-Proxy_Plugin
