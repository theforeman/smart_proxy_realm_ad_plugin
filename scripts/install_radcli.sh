#!/bin/sh
yum -y ruby gem ruby-devel
gem install rake bundler rakecompiler rspec
yum -y install automake autoconf xmlto xsltproc krb5-devel openldap-devel cyrus-sasl-devel

cd /home/vagrant/
git clone https://github.com/martencassel/radcli
chown -R vagrant.vagrant /home/vagrant/radcli/
cd /home/vagrant/radcli
su - vagrant -c "cd /home/vagrant/radcli && rake build && gem install pkg/radcli-0.1.0.gem"
