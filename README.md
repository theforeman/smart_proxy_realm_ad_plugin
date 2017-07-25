# Description
This plugin adds a new realm provider for managing hosts in Active Directory.

## Installation 
See How_to_Install_a_Smart-Proxy_Plugin for how to install Smart Proxy plugins

## Configuration

To enable this realm provider, edit `/etc/foreman-proxy/settings.d/realm.yml` and set:

    :enabled: true
    
    :use_provider: realm_ad
    
## Testing

     bundle exec rake test

## Install dependencies

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
gem install pkg/radcli-0.0.1.gem
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

