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
  
  def test_should_edit_template
    get :edit_template, { :edittheme => 'system', :template => 'test' }
    assert_rendered_file 'admin/theme/edit_template'
    assert assigns.has_key?('template_contents')
    assert assigns.has_key?('edittemplate')
    assert assigns.has_key?('theme')
    
    fpath = Theme::get_path.to_s + '/system/templates/test.rhtml'
    File.open(fpath, 'r') do |file|
      assert_equal assigns['template_contents'], file.read
    end
    
    post :do_edit_template, { :edittheme => 'system', :template => 'test', :template_contents => 'new' }
    assert_rendered_file 'admin/theme/templates'

    File.open(fpath, 'r') do |file|
      assert_equal 'new', file.read
    end
  end
  
  def test_should_view_template
    get :view_template, { :edittheme => 'system', :template => 'test' }
    assert_rendered_file 'admin/theme/view_template'
    assert assigns.has_key?('edittemplate')
    assert assigns.has_key?('theme')
  end
end
