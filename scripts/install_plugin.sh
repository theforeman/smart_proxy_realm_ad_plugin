# Add this line to your smart-proxy bundler.d/smart_proxy_realm_ad.rb gemfile

cat > /home/vagrant/smart-proxy/bundler.d/smart_proxy_realm_ad_plugin.rb << EOF
gem 'smart_proxy_real_ad_plugin.rb'
EOF

# And then execute
cd /home/vagrant/smart-proxy
bundle

# Or install it yourself
# gem install smart_proxy_realm_ad

# To configure this plugin you can use the template from 
# settings.d/smart_proxy_realm_ad.yml.example
cat > /home/vagrant/smart-proxy/settings.d/smart_proxy_realm_ad_plugin.yml << EOF
EOF


# You must place smart_proxy_realm_ad.yml config file (based on this template)
# to your smart-proxy config/settings.d/directory.

