# Status

Not ready yet, but almost....

# Description
This plugin adds a new realm provider for managing hosts in Active Directory.

Useful if you directly integrate with Active Directory and dont use FreeIPA. 

If you use this plugin you let foreman-proxy provision/deprovision computer accounts and password and also distribute the password to a kickstart file.

It does the following:

  * When hosts are created in foreman it will create a new computer account in active directory
    and return the password to foreman so it can be used in the kickstart file.
    
  * When hosts are rebuilt it will reset the computers account and return a new password to the kickstart file.

  * When hosts are deleted in foreman it will delete the associated computer account in active directory.
  
## Installation 
See How_to_Install_a_Smart-Proxy_Plugin for how to install Smart Proxy plugins.

Install this gem:

First clone this repo:
```
git clone https://github.com/martencassel/smart_proxy_realm_ad_plugin 
```

Then run bundle and gem install.

```
cd smart_proxy_realm_ad_plugin
bundle install && gem build smart_proxy_realm_ad_plugin.gemspec \
    && sudo gem install smart_proxy_realm_ad_plugin-0.1.gem

```

Then add the depedencies to to smart-proxy bundler.d directory like below:

Edit 'bundler.d/Gemfile.local.rb' and set:

    gem 'smart_proxy_realm_ad_plugin'
    gem 'radcli'
    gem 'rkerberos', '>= 0.1.1'
    gem 'passgen'

## Configuration

Then enable this as a realm provider in foreman-proxy

To enable this realm provider, edit `/etc/foreman-proxy/settings.d/realm.yml` and set:

    :enabled: true
    
    :use_provider: realm_ad
    
## Testing

     bundle exec rake test

## Install dependencies

Install the gem dependencies first:

  1. rkerberos
  2. radcli

### rkerberos
```
sudo gem install rkerberos
```

### radcli

#### radcli prereqs (ubuntu)
```
sudo apt-get install ruby gem ruby-dev
sudo gem install rake bundler rakecompiler rspec
sudo apt-get install automake autoconf xmlto xsltproc libkrb5-dev libldap2-dev libsasl2-dev
```

```
git clone https://github.com/martencassel/radcli
cd radcli
rake build
gem install pkg/radcli-0.1.0.gem
```

## Contributing

Fork and send a Pull Request. Thanks!

## Copyright

Copyright (c) 2016,2017 Mårten Cassel

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

