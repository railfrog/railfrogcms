require File.dirname(__FILE__) + '/../test_helper'

class SiteMappingTest < Test::Unit::TestCase
  fixtures :site_mappings 
  
  def setup 
  end

  def test_find_chunk_for_root
    chunk_version = SiteMapping.find_chunk("")
    assert_kind_of ChunkVersion, chunk_version
    assert_not_nil chunk_version
    assert_equal 2, chunk_version.id 
    assert_equal 2, chunk_version.version
    
    # FIXME: Enalbe to use following calls
    #assert_equal @second_version_of_index_page.content, chunk_version.content
    #assert_equal @chunk_versions["second_version_of_index_page"]["content"], chunk_version.content
  end

  def test_find_chunk_for_chocolate_cake
    chunk_version = SiteMapping.find_chunk(["products", "cakes", "chocolate_cake.html"])
    assert_kind_of ChunkVersion, chunk_version
    assert_not_nil chunk_version
    assert_equal 4, chunk_version.id 
    assert_equal 1, chunk_version.version
  end

  def test_find_chunk_for_unknown_path
    chunk_version = SiteMapping.find_chunk(["products", "cakes", "another_cake.html"])
    assert_equal nil, chunk_version

    chunk_version = SiteMapping.find_chunk(["services"])
    assert_equal nil, chunk_version
  end

  def test_find_layout_for_root
    layout = SiteMapping.find_layout("")
    assert_kind_of Layout, layout
    assert_not_nil layout
    assert_equal 1, layout.id 
    assert_equal "default", layout.name
  end

  def test_find_layout_for_chocolate_cake
    layout = SiteMapping.find_layout(["products", "cakes", "chocolate_cake.html"])
    assert_kind_of Layout, layout
    assert_not_nil layout
    assert_equal 2, layout.id 
    assert_equal "another", layout.name
  end

  def test_find_layout_for_unknown_path
    layout = SiteMapping.find_layout(["products", "cakes", "another_cake.html"])
    assert_equal nil, layout

    layout = SiteMapping.find_layout(["services"])
    assert_equal nil, layout
  end
  
  def test_full_path
    mapping = SiteMapping.find(1)
    assert_kind_of SiteMapping, mapping
    assert_not_nil mapping
    assert_equal "/", mapping.full_path

    mapping = SiteMapping.find(2)
    assert_kind_of SiteMapping, mapping
    assert_not_nil mapping
    assert_equal "/products", mapping.full_path

    mapping = SiteMapping.find(3)
    assert_kind_of SiteMapping, mapping
    assert_not_nil mapping
    assert_equal "/products/cakes", mapping.full_path

    mapping = SiteMapping.find(4)
    assert_kind_of SiteMapping, mapping
    assert_not_nil mapping
    assert_equal "/products/cakes/chocolate_cake.html", mapping.full_path
    
    mapping = SiteMapping.find(5)
    assert_kind_of SiteMapping, mapping
    assert_not_nil mapping
    assert_equal "/index.html", mapping.full_path

  end
end
