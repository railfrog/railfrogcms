require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase

  fixtures :users

  def setup
    @admin = users(:admin)
    assert_equal 1, User.count
  end

  def test_find_root
    assert_not_nil @admin
    assert_instance_of User, @admin
    assert_valid @admin
    assert @admin.errors.empty?
    assert_equal 'test@test.com', @admin.email
  end
end

