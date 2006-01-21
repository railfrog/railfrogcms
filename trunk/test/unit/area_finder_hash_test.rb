require File.dirname(__FILE__) + '/../test_helper'
require_dependency 'area_finder_hash'

class AreaFinderHashTest < Test::Unit::TestCase
  def test_should_add_area_to_array
    areashash = AreaFinderHash.new
    assert_match /^<div style=.+?>top<\/div>$/, areashash['top']
    assert_match /^<div style=.+?>bottom<\/div>$/, areashash['bottom']
    assert_equal ['top','bottom'], areashash.areas
    
    assert_match /#000000/, areashash['bla', { :border_color => '#000000' }]
    assert_match /#000000/, areashash['bla2', { :background_color => '#000000' }]
    assert_match /#000000/, areashash['bla3', { :padding => '#000000' }]
    assert_match /#000000/, areashash['bla4', { :font_color => '#000000' }]
  end
end