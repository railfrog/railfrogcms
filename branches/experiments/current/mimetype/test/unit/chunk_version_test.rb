require File.dirname(__FILE__) + '/../test_helper'

class ChunkVersionTest < Test::Unit::TestCase
  fixtures :chunk_versions

  def test_truth
    assert_instance_of ChunkVersion, ChunkVersion.find(:first)
  end
end

