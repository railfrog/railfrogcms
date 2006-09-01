require File.dirname(__FILE__) + '/../test_helper'

class ChunkTest < Test::Unit::TestCase
  fixtures :chunks

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Chunk, Chunk.find(:first)
  end
end
