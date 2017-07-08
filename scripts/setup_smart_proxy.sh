#!/bin/sh

#
# Vagrant runs this as root
#

yum -y install wget ruby git ruby-devel
gem install json_pure
gem update --system

gem install bundler
gem install rdoc

yum -y install libvirt-devel
gem install ruby-libvirt
yum -y install augeas-devel

yum -y install byacc
wget http://web.mit.edu/kerberos/dist/krb5/1.14/krb5-1.14.tar.gz
tar -xzf krb5-1.14.tar.gz
cd krb5-1.14/src
export CPPFLAGS='-I/usr/local/opt/openssl/include'
export LDFLAGS='-L/usr/local/opt/openssl/lib'
./configure
make
make install
gem install rkerberos

cd /home/vagrant
git clone git://github.com/theforeman/smart-proxy.git
cd /home/vagrant/smart-proxy
chown -R vagrant.vagrant /home/vagrant/smart-proxy/
su - vagrant -c "cd /home/vagrant/smart-proxy && bundle"
