require File.dirname(__FILE__) + '/../test_helper'

class FileExtensionTest < Test::Unit::TestCase
  fixtures :file_extensions

  # Replace this with your real tests.
  def test_truth
    assert_kind_of FileExtension, file_extensions(:first)
  end
end
