require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/theme_controller'

# Re-raise errors caught by the controller.
class Admin::ThemeController; def rescue_action(e) raise e end; end

class Admin::ThemeControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::ThemeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    set_good_theme_path
    set_fake_renderer
  end

  def test_should_list_themes_on_index
    get :index
    assert assigns.has_key?('themes')
    assert_rendered_file 'admin/theme/index'
  end
  
  def test_should_list_templates_on_request
    get :templates, { :id => 'system' }
    assert_rendered_file 'admin/theme/templates'
    assert assigns.has_key?('templates')
  end
end
