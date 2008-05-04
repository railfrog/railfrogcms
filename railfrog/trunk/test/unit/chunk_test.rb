require File.dirname(__FILE__) + '/../test_helper'

class ChunkTest < Test::Unit::TestCase
  fixtures :chunks

  def test_truth
    assert_instance_of Chunk, Chunk.find(:first)
  end
end

