require 'rubygems'
require 'test_helper'
require 'smart_proxy_realm_ad/provider'
require 'radcli'

class RealmAdTest < Test::Unit::TestCase
  def setup
    @realm = 'test_realm'
    @provider = Proxy::AdRealm::Provider.new('example.com', 'keytab_path', 'principal', 'domain-controller', nil)
  end

  def test_create_host
    hostname = 'host.example.com'
    params = {}
    params[:rebuild] = 'false'
    @provider.expects(:check_realm).with(@realm)
    @provider.expects(:kinit_radcli_connect)
    @provider.expects(:radcli_join)
    response = JSON.parse(@provider.create(@realm, hostname, params))
    assert_kind_of String, response['randompassword']
    assert_equal 20, response['randompassword'].size
  end

  def test_create_with_unrecognized_realm_raises_exception
    assert_raises(Exception) { @provider.create('unknown_realm', 'a_host', {}) }
  end

  def test_create_rebuild
    hostname = 'host.example.com'
    params = {}
    params[:rebuild] = 'true'
    @provider.expects(:check_realm).with(@realm)
    @provider.expects(:kinit_radcli_connect)
    @provider.expects(:radcli_password)
    response = JSON.parse(@provider.create(@realm, hostname, params))
    assert_kind_of String, response['randompassword']
    assert_equal 20, response['randompassword'].size
  end

  def test_rebuild_with_unrecognized_realm_raises_exception
    params = {}
    params[:rebuild] = 'true'
    assert_raises(Exception) { @provider.create('unknown_realm', 'a_host', params) }
  end

  def test_find
    assert_true @provider.find('a_host_fqdn')
  end

  def test_delete
    @provider.expects(:check_realm).with(@realm)
    @provider.expects(:kinit_radcli_connect)
    @provider.expects(:radcli_delete)
    @provider.delete(@realm, 'a_host')
  end

  def test_delete_unrecognized_realm_raises_exception
    @provider.expects(:kinit_radcli_connect)
    assert_raises(Exception) { @provider.delete('unkown_realm', 'a_host') }
  end
end
