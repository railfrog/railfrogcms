require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../lib/site_loader'

class SiteLoaderTest < Test::Unit::TestCase
  include Railfrog

  fixtures :site_mappings, :mapping_labels

  def setup
    SiteMapping.find_root.destroy
    Chunk.destroy_all
    @dir = "test/fixtures/site_loader/without_site_yml"
    assert_equal 0, SiteMapping.count
    assert_equal 0, MappingLabel.count
    assert_equal 0, Chunk.count
    assert_equal 0, ChunkVersion.count
  end

  def test_load_site
    dir = "no/such/dir"
    exc = assert_raise(RuntimeError) { SiteLoader.load_site(dir) }
    assert_equal "There is no such dir #{dir}", exc.message
  end

  def test_empty_site
    dir = File.join(@dir, "empty_site")
    SiteLoader.load_site(dir)
    assert_equal 1, SiteMapping.count
    assert_equal 0, MappingLabel.count
    assert_equal 0, Chunk.count
    assert_equal 0, ChunkVersion.count
  end

  def test_files_only
    dir = File.join(@dir, "files_only")
    SiteLoader.load_site(dir)
    assert_equal 4, SiteMapping.count
    assert_equal 0, MappingLabel.count
    assert_equal 3, Chunk.count
    assert_equal 3, ChunkVersion.count

    assert_not_nil SiteMapping.find_mapping(['file1.txt'])
    assert_not_nil SiteMapping.find_mapping(['file2.html'])
    assert_not_nil SiteMapping.find_mapping(['railfrog.jpg'])
  end

  def test_dirs_only
    dir = File.join(@dir, "dirs_only")
    SiteLoader.load_site(dir)
    assert_equal 5, SiteMapping.count
    assert_equal 0, MappingLabel.count
    assert_equal 0, Chunk.count
    assert_equal 0, ChunkVersion.count

    assert_not_nil SiteMapping.find_mapping(['dir1'])
    assert_not_nil SiteMapping.find_mapping(['dir1', 'dir2'])
    assert_not_nil SiteMapping.find_mapping(['dir1', 'dir2', 'dir3'])
    assert_not_nil SiteMapping.find_mapping(['dir4'])
  end

  def test_mixed
    dir = File.join(@dir, "mixed")
    SiteLoader.load_site(dir)
    assert_equal 10, SiteMapping.count
    assert_equal 0, MappingLabel.count
    assert_equal 5, Chunk.count
    assert_equal 5, ChunkVersion.count

    assert_not_nil SiteMapping.find_mapping(['index.html'])
    assert_not_nil SiteMapping.find_mapping(['images', 'altai.jpg'])
    assert_not_nil SiteMapping.find_mapping(['posts', 'cultural_notes', 'index.html'])
  end

end

