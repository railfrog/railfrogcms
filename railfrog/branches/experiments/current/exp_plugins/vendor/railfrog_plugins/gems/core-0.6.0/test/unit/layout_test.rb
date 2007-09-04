require File.dirname(__FILE__) + '/../test_helper'

class LayoutTest < Test::Unit::TestCase
  fixtures :layouts

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Layout, Layout.find(:first)
  end
end
