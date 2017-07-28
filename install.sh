#!/bin/sh

bundle install && gem build smart_proxy_realm_ad_plugin.gemspec && sudo gem install smart_proxy_realm_ad_plugin-0.1.gem
