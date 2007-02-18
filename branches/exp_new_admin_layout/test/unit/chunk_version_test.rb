require File.dirname(__FILE__) + '/../test_helper'

class ChunkVersionTest < Test::Unit::TestCase
  fixtures :chunk_versions

  # Replace this with your real tests.
  def test_truth
    assert_kind_of ChunkVersion, ChunkVersion.find(:first)
  end
end
