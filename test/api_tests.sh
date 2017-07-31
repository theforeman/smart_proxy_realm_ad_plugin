#!/bin/sh

# ping smart-proxy
curl -H "Accept: application/json" http://localhost:8000/features

# create host
curl -d 'hostname=server1.example.com' http://localhost:8000/realm/EXAMPLE.COM

# rebuild host
curl -d 'hostname=server1.example.com&rebuild=true' http://localhost:8000/realm/EXAMPLE.COM

# delete host
curl -XDELETE http://localhost:8000/realm/EXAMPLE.COM/server1.example.com

