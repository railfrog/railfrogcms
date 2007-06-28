require File.dirname(__FILE__) + '/../test_helper'

class MimeTypeTest < Test::Unit::TestCase
  fixtures :mime_types

  def test_truth
    assert_instance_of MimeType, MimeType.find(:first)
  end
end

