require File.dirname(__FILE__) + '/../test_helper'
require_dependency 'area_finder_hash'

class AreaHashTest < Test::Unit::TestCase
  def test_should_add_area_to_array
    areashash = AreaHash.new
    assert_match /^<div id=.+? class=.+?>top<\/div>$/, areashash['top']
    assert_match /^<div id=.+? class=.+?>bottom<\/div>$/, areashash['bottom']
    assert_equal({"top" => "", "bottom" => ""}, areashash.areas)
  end
end