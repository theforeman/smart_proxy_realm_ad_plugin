source 'https://rubygems.org'
gemspec

group :development do
  if RUBY_VERSION < '2.2.2'
    gem 'rack-test', '~> 0.7.0'
  else
    gem 'rack-test'
  end

  gem 'smart_proxy', :git => 'https://github.com/theforeman/smart-proxy.git', :branch => 'develop'
end
