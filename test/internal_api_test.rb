require 'test_helper'
require 'rack/test'
require 'realm/configuration_loader'
require 'smart_proxy_realm_ad_plugin'
require 'smart_proxy_realm_ad/provider'

ENV['RACK_ENV'] = 'test'

module Proxy::Realm
  module DependencyInjection
    include Proxy::DependencyInjection::Accessors
    def container_instance; end
  end
end

require 'realm/realm_api'

class InternalApiTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    app = Proxy::Realm::Api.new
    app.helpers.realm_provider = @server
    app
  end

  def setup
    @server = Proxy::AdRealm::Provider.new(:realm => "test.com")
  end

  def test_create_host
    realm = "TEST.COM"
    hostname = "test.com"
    @server.expects(:create).with(realm, hostname, is_a(Hash))
    post "/#{realm}", :hostname => 'test.com'
    assert last_response.ok?, "Last response was not ok: #{last_response.status} #{last_response.body}"
  end

  def test_rebuild_host
    realm = "TEST.COM"
    hostname = "test.com"
    @server.expects(:create).with(realm, hostname, has_entry('rebuild', 'true'))
    post "/#{realm}", :hostname => 'test.com', :rebuild => true
    assert last_response.ok?, "Last response was not ok: #{last_response.status} #{last_response.body}"
  end

  def test_delete_host
    realm = "TEST.COM"
    hostname = "test.com"
    @server.expects(:delete).with(realm, hostname)
    delete "/#{realm}/#{hostname}"
    assert last_response.ok?, "Last response was not ok: #{last_response.status} #{last_response.body}"
  end
end
