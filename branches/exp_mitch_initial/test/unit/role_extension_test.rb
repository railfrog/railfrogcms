require File.dirname(__FILE__) + '/../test_helper'

class RoleExtensionTest < Test::Unit::TestCase
  fixtures :role_extensions

  # Replace this with your real tests.
  def test_truth
    assert_kind_of RoleExtension, role_extensions(:first)
  end
end
