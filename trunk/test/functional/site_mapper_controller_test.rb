require File.dirname(__FILE__) + '/../test_helper'
require 'site_mapper_controller'

# Re-raise errors caught by the controller.
class SiteMapperController; def rescue_action(e) raise e end; end

class SiteMapperControllerTest < Test::Unit::TestCase
#  fixture_path = File.dirname(__FILE__) + '/../fixtures/railfrog'
  fixtures :site_mappings, :mapping_labels, :chunks, :chunk_versions, :mime_types, :file_extensions


  def setup
    @controller = SiteMapperController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

    # 1. check layout
    # 2. check labels
    # 3. check internal

  def test_index_html
    get :show_chunk, :path => ['index.html']
    assert_response :success
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
