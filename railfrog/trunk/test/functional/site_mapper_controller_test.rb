require File.dirname(__FILE__) + '/../test_helper'
require 'site_mapper_controller'

# Re-raise errors caught by the controller.
class SiteMapperController; def rescue_action(e) raise e end; end

class SiteMapperControllerTest < Test::Unit::TestCase
  FIXTURES = ['site_mappings', 'mapping_labels', 'chunks', 'chunk_versions']

  def setup
    @controller = SiteMapperController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    SiteMapping.delete_all
    MappingLabel.delete_all
    Chunk.delete_all
    ChunkVersion.delete_all
    MimeType.delete_all
    FileExtension.delete_all

    assert_equal 0, SiteMapping.count, "But got #{SiteMapping.count}"
    assert_equal 0, MappingLabel.count
    assert_equal 0, Chunk.count
    assert_equal 0, ChunkVersion.count


    FIXTURES.each {|f|
      fs = Fixtures.create_fixtures(RAILS_ROOT + "/test/fixtures/railfrog/", f)
    }

    assert_equal 20, SiteMapping.count, "But got #{SiteMapping.count}"
    assert_equal 5, MappingLabel.count
    assert_equal 16, Chunk.count
    assert_equal 16, ChunkVersion.count
  end

    # 1. check layout
    # 2. check labels
    # 3. check internal

  def test_
    get :show_chunk, :path => ['']
    assert_response :success
    assert_select 'title', { :text => 'Railfrog / CMS Ridin&rsquo; on Rails', :count => 1 }
  end

  def test_index_html
    get :show_chunk, :path => ['index.html']
    assert_response :success
    assert_select 'title', { :text => 'Railfrog / CMS Ridin&rsquo; on Rails', :count => 1 }
    assert_select 'li.first-child a', 'About'
    assert_select 'h2', 'A modest proposal'
  end

  def test_internal
    get :show_chunk, :path => ['layout']
    assert_response :missing

    SiteMapping.find(:all, :conditions => { :is_internal => true}).each {|m|
      get :show_chunk, :path => m.full_path.split('/')
      assert_response :missing
      assert_not_nil SiteMapping.find_mapping(m.full_path.split('/'))
    }
  end

  def test_404
    get :show_chunk, :path => ['no', 'such', 'file']
    assert_response :missing
  end
end

def test_create_chunk  # TODO implement
  true
end
