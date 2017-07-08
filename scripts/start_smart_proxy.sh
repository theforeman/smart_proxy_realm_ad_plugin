#!/bin/sh

cat >/home/vagrant/smart-proxy/config/settings.yml << EOF
:bind_host: ['*']
:http_port: 8000
:log_file: /var/log/foreman-proxy/proxy.log
:log_level: DEBUG
EOF

sudo mkdir -p /var/log/foreman-proxy
sudo chown -R vagrant.vagrant /var/log/foreman-proxy
/home/vagrant/smart-proxy/bin/smart-proxy &
tail -f /var/log/foreman-proxy/proxy.log