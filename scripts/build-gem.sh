#!/bin/bash

# Set flag
set -e

# Ensure podman or docker is installed
if ! command -v podman &> /dev/null; then
  if ! command -v docker &> /dev/null; then
    echo "Neither podman nor docker is installed"
    exit 1
  fi
fi

# Check distro and install dependencies
if [ -f /etc/redhat-release ]; then
  echo "RHEL"
  sudo yum install -y ruby ruby-devel rubygems gcc
elif [ -f /etc/debian_version ]; then
  echo "Debian"
  sudo apt-get install -y ruby ruby-dev rubygems gcc
else
  echo "Unsupported distro"
  exit 1
fi

cd ..

cat <<EOF > /tmp/Dockerfile
FROM ruby:2.7
WORKDIR /app
COPY . .
RUN apt-get update && apt-get install libldap-dev libsasl2-dev
RUN bundle install
RUN gem build smart_proxy_realm_ad_plugin.gemspec
EOF

# Build the image
if command -v podman &> /dev/null; then
  podman build -t my-ruby-app -f /tmp/Dockerfile .
elif command -v docker &> /dev/null; then
  docker build -t my-ruby-app -f /tmp/Dockerfile .
fi

docker rm -f builder||true
docker run -d --name=builder my-ruby-app:latest sleep infinity
docker cp builder:/app/smart_proxy_realm_ad_plugin-0.1.gem .


