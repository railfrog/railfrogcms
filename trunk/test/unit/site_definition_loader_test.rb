require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../lib/site_loader'
require File.dirname(__FILE__) + '/../../lib/definition_loader'

class SiteDefinitionLoaderTest < Test::Unit::TestCase
  include Railfrog

  fixtures :site_mappings, :mapping_labels, :chunks, :chunk_versions

  def setup
    SiteMapping.find_root.destroy
    Chunk.destroy_all
    @dir = "test/fixtures/site_loader/with_site_yml"
    assert_equal 0, SiteMapping.count
    assert_equal 0, MappingLabel.count
    assert_equal 0, Chunk.count
    assert_equal 0, ChunkVersion.count
  end

  def test_empty_site_yml
    dir = File.join(@dir, "empty_site_yml")
    exc = assert_raise(RuntimeError) { SiteLoader.load_site(dir) }
    assert_equal "site.yml file is empty", exc.message

    assert_equal 0, SiteMapping.count
    assert_equal 0, MappingLabel.count
    assert_equal 0, Chunk.count
    assert_equal 0, ChunkVersion.count
  end

  def test_site_yml_contains_no_root
    dir = File.join(@dir, "site_yml_contains_no_root_tag")
    exc = assert_raise(RuntimeError) { SiteLoader.load_site(dir)  }
    assert_equal "site.yml file contains no 'root' tag", exc.message

    assert_equal 0, SiteMapping.count
    assert_equal 0, MappingLabel.count
    assert_equal 0, Chunk.count
    assert_equal 0, ChunkVersion.count
  end

  def test_site_yml_only
    dir = File.join(@dir, "site_yml_only")
    assert_nothing_raised { SiteLoader.load_site(dir)  }

    assert_equal 8, SiteMapping.count
    assert_equal 6, MappingLabel.count
    assert_equal 4, Chunk.count
    assert_equal 4, ChunkVersion.count

    # check site_mappings
    assert_not_nil SiteMapping.find_mapping(['dir1', 'dir2'])
    assert_not_nil SiteMapping.find_mapping(['layouts'])

    assert_not_nil SiteMapping.find_mapping(['dir1', 'dir2', 'pond.html'])
    assert_not_nil SiteMapping.find_mapping(['index.html'])
    assert_not_nil SiteMapping.find_mapping(['internal-index.html'])
    assert_not_nil SiteMapping.find_mapping(['layouts', 'header'])

    # check chunks
    assert_nil SiteMapping.find_mapping_and_labels_and_chunk([])[2]
    assert_nil SiteMapping.find_mapping_and_labels_and_chunk(['dir1', 'dir2'])[2]
    assert_nil SiteMapping.find_mapping_and_labels_and_chunk(['layouts'])[2]

    assert_not_nil SiteMapping.find_mapping_and_labels_and_chunk(['dir1', 'dir2', 'pond.html'])[2]
    assert_not_nil SiteMapping.find_mapping_and_labels_and_chunk(['index.html'])[2]
    assert_not_nil SiteMapping.find_mapping_and_labels_and_chunk(['internal-index.html'])[2]
    assert_not_nil SiteMapping.find_mapping_and_labels_and_chunk(['layouts', 'header'])[2]

    # check is_internal
    assert_equal 3, SiteMapping.find(:all, :conditions => { :is_internal => true }).size
    assert SiteMapping.find_mapping(['internal-index.html']).is_internal
    assert SiteMapping.find_mapping(['layouts']).is_internal
    assert SiteMapping.find_mapping(['layouts', 'header']).is_internal

    assert !SiteMapping.find_mapping(['index.html']).is_internal
    assert !SiteMapping.find_mapping(['dir1']).is_internal
    assert !SiteMapping.find_mapping(['dir1', 'dir2', 'pond.html']).is_internal

    # check labels
    assert_equal 2, SiteMapping.find_mapping.mapping_labels.size

    assert_equal 1, SiteMapping.find_mapping(['index.html']).mapping_labels.size
    assert_equal 2, SiteMapping.find_mapping(['index.html']).parent_mapping.mapping_labels.size

    assert_equal 0, SiteMapping.find_mapping(['dir1']).mapping_labels.size
    assert_equal 0, SiteMapping.find_mapping(['dir1', 'dir2']).mapping_labels.size
    assert_equal 1, SiteMapping.find_mapping(['dir1', 'dir2', 'pond.html']).mapping_labels.size

    assert_equal 0, SiteMapping.find_mapping(['internal-index.html']).mapping_labels.size
  end

  def test_railfrog
    dir = File.join("db/sites/railfrog")
    assert_nothing_raised { SiteLoader.load_site(dir)  }

    assert_equal 20, SiteMapping.count
    assert_equal 5, MappingLabel.count
    assert_equal 16, Chunk.count
    assert_equal 16, ChunkVersion.count

    # check site_mappings
    assert_not_nil SiteMapping.find_mapping(['images'])
    assert_not_nil SiteMapping.find_mapping(['layout'])
    assert_not_nil SiteMapping.find_mapping(['styles'])

    assert_not_nil SiteMapping.find_mapping(['images', 'railfrog_orig.jpg'])
    assert_not_nil SiteMapping.find_mapping(['index.html'])
    assert_not_nil SiteMapping.find_mapping(['pond.html'])

    # check chunks
    assert_nil SiteMapping.find_mapping_and_labels_and_chunk([])[2]
    assert_nil SiteMapping.find_mapping_and_labels_and_chunk(['images'])[2]
    assert_nil SiteMapping.find_mapping_and_labels_and_chunk(['layout'])[2]

    assert_not_nil SiteMapping.find_mapping_and_labels_and_chunk(['pond.html'])[2]
    assert_not_nil SiteMapping.find_mapping_and_labels_and_chunk(['index.html'])[2]
    assert_not_nil SiteMapping.find_mapping_and_labels_and_chunk(['images', 'railfrog_orig.jpg'])[2]
    assert_not_nil SiteMapping.find_mapping_and_labels_and_chunk(['layout', 'header'])[2]

    # check is_internal
    assert_equal 5, SiteMapping.find(:all, :conditions => { :is_internal => true }).size
    assert SiteMapping.find_mapping(['layout']).is_internal
    assert SiteMapping.find_mapping(['layout', 'header']).is_internal

    assert !SiteMapping.find_mapping(['index.html']).is_internal
    assert !SiteMapping.find_mapping(['images']).is_internal

    # check labels
    assert_equal 2, SiteMapping.find_mapping.mapping_labels.size

    assert_equal 1, SiteMapping.find_mapping(['index.html']).mapping_labels.size
    assert_equal 2, SiteMapping.find_mapping(['index.html']).parent_mapping.mapping_labels.size

    assert_equal 0, SiteMapping.find_mapping(['images']).mapping_labels.size
  end

end


