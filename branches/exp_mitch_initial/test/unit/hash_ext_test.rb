require File.dirname(__FILE__) + '/../test_helper'

class HashExtTest < Test::Unit::TestCase
  def test_should_retrive_hash_value_from_period
    bla = { 'key' => 'value' }
    assert_equal bla['key'], 'value'
    assert_equal bla.key, 'value'
  end
  
  def test_should_retrieve_hash_value_from_period_with_symbol
    bla = { :key => 'value' }
    assert_equal bla[:key], 'value'
    assert_equal bla.key, 'value'
  end
  
  def test_should_return_nil_on_bad_key
    bla = {}
    assert_nil bla.ah
  end
  
  def test_should_create_activerecord_errors_object
    bla = {}
    assert_kind_of Hash, bla.create_errors_object
    assert_kind_of ActiveRecord::Errors, bla.errors
    assert bla.errors.add('Test', 'is a bad bad man')
    assert bla.errors.on('Test')
  end
end