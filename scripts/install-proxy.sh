#!/bin/bash

# Check distro and install dependencies
if [ -f /etc/redhat-release ]; then
  # CHeck for RHEL 9
  if grep -q "Red Hat Enterprise Linux 9" /etc/redhat-release; then
    echo "RHEL 9"
    sudo dnf update 
    sudo dnf clean all
    sudo dnf install -y https://yum.theforeman.org/releases/nightly/el9/x86_64/foreman-release.rpm
    sudo dnf install -y https://yum.puppet.com/puppet7-release-el-9.noarch.rpm
    sudo dnf repolist enabled
    sudo dnf upgrade
    sudo dnf install -y foreman-installer
    sudo dnf -y install rubygem-radcli rubygem-smart_proxy_realm_ad_plugin
  fi
  # Not supported yet
  echo "The script does not support this version of RHEL"
elif [ -f /etc/debian_version ]; then
  echo "Debian"
  echo "Not implemented"
else
  echo "Unsupported distro"
  exit 1
fi