#!/bin/sh
echo "nameserver $DNS_SERVER" > /tmp/resolv.conf
echo "search $DNS_SEARCH" >> /tmp/resolv.conf
echo "domain $DOMAIN" >> /tmp/resolv.conf
cat /tmp/resolv.conf > /etc/resolv.conf
exec "$@"