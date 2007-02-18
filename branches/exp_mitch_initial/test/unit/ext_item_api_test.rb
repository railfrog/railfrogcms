require File.dirname(__FILE__) + '/../test_helper'

class ExtItemApiTest < Test::Unit::TestCase
  def test_should_call_methods_with_arguments_too
    assert ExtensionAPI::Item.add_method('args_method', method(:meth_args))
    assert_equal 'String', ExtensionAPI::Item.args_method('what am i?')
    assert_equal 'Hash', ExtensionAPI::Item.args_method({ :a => :b })
  end

  def test_should_add_single_method_and_call_previous
    meths = { 'test_meth' => method(:meth_test) }
    assert ExtensionAPI::Item.set_methods(meths)
    assert_equal 'cool', ExtensionAPI::Item.test_meth
    assert ExtensionAPI::Item.add_method('the_add_method', method(:meth_add))
    assert_equal 'yes', ExtensionAPI::Item.the_add_method
    assert_equal 'cool', ExtensionAPI::Item.test_meth
  end

  def test_should_return_false_on_non_hash
    assert_equal false, ExtensionAPI::Item.set_methods('hi')
  end
  
  def test_should_return_false_on_invalid_values
    invalid_one = { { 'haha' => 'bad' } => method(:meth_test) }
    invalid_two = { 2 => method(:meth_test) }
    invalid_three = { 'hi' => 'hi again' }
    assert_equal false, ExtensionAPI::Item.set_methods(invalid_one)
    assert_equal false, ExtensionAPI::Item.set_methods(invalid_two)
    assert_equal false, ExtensionAPI::Item.set_methods(invalid_three)
  end
  
  def test_should_set_and_call_methods
    meths = { 'test_meth' => method(:meth_test) }
    assert ExtensionAPI::Item.set_methods(meths)
    assert_equal 'cool', ExtensionAPI::Item.test_meth
    assert_equal 'cool', ExtensionAPI::Item.call_test_meth
    assert_equal 'cool', ExtensionAPI::Item.call_method(:test_meth)
    assert_equal 'cool', ExtensionAPI::Item.call_method('test_meth')
  end
  
  def meth_test
    return 'cool'
  end
  
  def meth_add
    return 'yes'
  end
  
  def meth_args(hi)
    return hi.class.to_s
  end
end