# Description
A plugin to foreman smart-proxy that lets you 
integrate directly with Active Directory to manage hosts
during creation, rebuilding and deletion of their 
computer account and the credentials.

# TODO

## Objective 1. Setup a dev environment 

The dev environment consists of a Active Directory domain controller 
plus a centos 7 server running smart-proxy

## Objective 2. Load the plugin

Load a dummy version of the plugin and ensure its loaded with smart-proxy.

## Objective 3. Make sure the plugins API functions gets invoked through the realm api

Use curl and trigger join, reset and delete api operations. Log the request
through the logger of smart-proxy.

## Objective 4. Implement different realm api operations

Use curl and implement the plugin operations: join, reset, delete

# Installation
lorem ipsum

### Prerequisites
lorem ipsum

```
some commands
```

### Building
```
some commands
```

# Synposis


# Notes

# Authors
* Mårten Cassel
 
 
WORK IN PROGRESS

A smart-proxy realm provider plugin for direct integration 
with Active Directory.

Using this plugin, foreman is capable of managing a hosts Active Directory
credential and account during the host lifecycle.


