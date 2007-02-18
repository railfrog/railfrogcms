require File.dirname(__FILE__) + '/../test_helper'

class ObjectExtTest < Test::Unit::TestCase
  def test_block_behaves_like_instance_method
    assert_equal self, instance_call(&@@block_returns_self)
    #implement: test if return works
  end
  @@block_returns_self = lambda { self }
  
  def test_should_get_extensions
    @extensions = get_extensions(:ext_point)
    assert_kind_of Array, @extensions
    @extensions.each { |extension| assert_kind_of Proc, extension }
  end
  
  def test_should_invoke_single_extensions
    @extensions = get_extensions(:ext_point)
    @extensions.each do |extension|
      assert ["First extension", "Hello, Nobody"].include?(\
                       invoke_extension(extension, "Nobody"))
    end
  end
  
  def test_should_invoke_all_extensions
    assert_equal ["First extension", "Hello, Nobody"],
                 invoke_extensions(:ext_point, "Nobody")
  end
  
  def test_should_invoke_extensions_individually
    assert_equal ["first extension", "hello, nobody"],
                 each_extension(:ext_point, "Nobody") { |res| res.downcase! }
  end
  
  def_extension(:ext_point) do
    "First extension"
  end
  
  def_extension(:ext_point) do |name|
    "Hello, " + name
  end
end