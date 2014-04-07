# -*- ruby encoding: utf-8 -*-

require 'marketo-api-ruby'

def try_require(resource)
  require resource
  yield if block_given?
rescue LoadError
end

gem 'minitest'
require 'minitest/autorun'
try_require 'minitest/emoji'

module MarketoTestHelper
  def setup
    super
    @client = MarketoAPI.client(user_id: 'user', encryption_key: 'key')
  end

  attr_reader :subject

  def stub_specialized method, object = subject, &block
    object.stub method, ->(*args) { args } do
      block.call if block
    end
  end

  def stub_soap_call object = subject, &block
    object.stub :call, ->(*args) { args } do
      block.call if block
    end
  end

  def lead_key *ids
    keys = ids.map { |id| MarketoAPI::Lead.key(:id, id) }
    case
    when keys.empty?
      nil
    when keys.size == 1
      keys.first
    else
      keys
    end
  end
  alias_method :lead_keys, :lead_key

  def assert_missing_keys object, *keys
    keys.each { |key| refute object.has_key? key }
  end

  def refute_missing_keys object, *keys
    keys.each { |key| assert object.has_key? key }
  end
end