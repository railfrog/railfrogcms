require File.dirname(__FILE__) + '/../test_helper'

class SiteMappingTest < Test::Unit::TestCase
  fixtures :site_mappings

  # Replace this with your real tests.
  def test_truth
    assert_kind_of SiteMapping, site_mappings(:first)
  end
end
