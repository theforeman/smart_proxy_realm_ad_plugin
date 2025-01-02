require 'rubygems'
require 'test_helper'
require 'smart_proxy_realm_ad/provider'
require 'radcli'

class RealmAdTest < Test::Unit::TestCase
  def setup
    @realm = 'test_realm'
    @provider = Proxy::AdRealm::Provider.new(
      realm: 'example.com',
      keytab_path: 'keytab_path',
      principal: 'principal',
      domain_controller: 'domain-controller',
      ou: nil,
      computername_prefix: nil,
      computername_hash: false,
      computername_use_fqdn: false
    )
  end

  def test_create_host
    hostname = 'host.example.com'
    computername = 'HOST'
    params = {
      rebuild: 'false'
    }
    @provider.expects(:check_realm).with(@realm)
    @provider.expects(:kinit_radcli_connect)
    @provider.expects(:generate_password).returns('password')
    @provider.expects(:radcli_join).with(hostname, computername, 'password')
    @provider.create(@realm, hostname, params)
  end

  def test_create_host_returns_password
    hostname = 'host.example.com'
    params = {
        rebuild: 'false'
    }

    @provider.stubs(:check_realm)
    @provider.stubs(:kinit_radcli_connect)
    @provider.stubs(:radcli_join)

    response = JSON.parse(@provider.create(@realm, hostname, params))

    assert_kind_of String, response['randompassword']
  end

  def test_rebuild_host
    hostname = 'host.example.com'
    params = {}
    params[:rebuild] = 'true'
    @provider.expects(:check_realm).with(@realm)
    @provider.expects(:kinit_radcli_connect)
    @provider.expects(:radcli_password)
    @provider.create(@realm, hostname, params)
  end

  def test_rebuild_host_returns_password
    hostname = 'host.example.com'
    params = {
        rebuild: 'true'
    }

    @provider.stubs(:check_realm)
    @provider.stubs(:kinit_radcli_connect)
    @provider.stubs(:radcli_password)

    response = JSON.parse(@provider.create(@realm, hostname, params))

    assert_kind_of String, response['randompassword']
  end

  def test_generate_password_returns_random_passwords
    refute_equal @provider.generate_password, @provider.generate_password
  end

  def test_generate_password_returns_20_char_long_password
    assert_equal 20, @provider.generate_password.size
  end

  def test_apply_computername_prefix_should_return_false_when_prefix_is_nil
    provider = Proxy::AdRealm::Provider.new(computername_prefix: nil, realm: 'example.com')
    refute provider.apply_computername_prefix?('host.example.com')
  end

  def test_apply_computername_prefix_should_return_false_when_prefix_is_empty
    provider = Proxy::AdRealm::Provider.new(computername_prefix: '', realm: 'example.com')
    refute provider.apply_computername_prefix?('host.example.com')
  end

  def test_apply_computername_prefix_should_return_false_when_hostname_contains_prefix
    provider = Proxy::AdRealm::Provider.new(computername_prefix: 'PREFIX-', realm: 'example.com')
    refute provider.apply_computername_prefix?('prefix-host.example.com')
  end

  def test_apply_computername_prefix_should_return_true_when_computername_hash_is_used
    provider = Proxy::AdRealm::Provider.new(computername_prefix: 'PREFIX-', computername_hash: true, realm: 'example.com')
    assert provider.apply_computername_prefix?('host.example.com')
  end

  def test_hostfqdn_to_computername_uses_prefix
    provider = Proxy::AdRealm::Provider.new(computername_prefix: 'ORG-', realm: 'example.com')
    assert_equal 'ORG-HOST', provider.hostfqdn_to_computername('host.example.com')
  end

  def test_hostfqdn_to_computername_is_limited_to_15_characters
    provider = Proxy::AdRealm::Provider.new(realm: 'example.com')
    assert_equal 15, provider.hostfqdn_to_computername('superlonghostname.example.com').size
  end

  def test_hostfqdn_to_computername_applies_sha256
    provider = Proxy::AdRealm::Provider.new(computername_hash: true, realm: 'example.com')
    assert_equal '4740AE6347B0172', provider.hostfqdn_to_computername('host.example.com')
  end

  def test_unrecognized_realm_raises_exception
    assert_raises(Exception) { @provider.check_realm('unknown_realm') }
  end

  def test_find
    assert @provider.find('a_host_fqdn')
  end

  def test_delete
    @provider.expects(:check_realm).with(@realm)
    @provider.expects(:kinit_radcli_connect)
    @provider.expects(:radcli_delete).with('HOST')
    @provider.delete(@realm, 'host.example.com')
  end
end
