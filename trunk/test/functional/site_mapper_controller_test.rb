require File.dirname(__FILE__) + '/../test_helper'
require 'site_mapper_controller'

# Re-raise errors caught by the controller.
class SiteMapperController; def rescue_action(e) raise e end; end

class SiteMapperControllerTest < Test::Unit::TestCase
  fixtures :chunks

  def setup
    @controller = SiteMapperController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    assert true
  end

end
