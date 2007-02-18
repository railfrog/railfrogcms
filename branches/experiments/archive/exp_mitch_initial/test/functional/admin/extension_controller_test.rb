require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/extension_controller'

# Re-raise errors caught by the controller.
class Admin::ExtensionController; def rescue_action(e) raise e end; end

class Admin::ExtensionControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::ExtensionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    set_good_extension_path
    set_fake_renderer
    Extension.install('static') unless Extension.exists?('static')
    Extension.install('not_installed') unless Extension.exists?('not_installed')
    Extension.install('bold') unless Extension.exists?('bold')
  end

  def test_should_set_extensions_array_on_index
    get :index
    assert_not_nil assigns['extensions']
    assert_kind_of Array, assigns['extensions']
    assert_rendered_file 'admin/extension/index'
  end
  
  def test_should_show_index_on_uninstalling_nonexistent_extension
    get :uninstall, { :id => 'i-dont-exist-hehe' }
    assert_rendered_file 'admin/extension/index'
  end
  
  def test_should_set_error_in_flash_on_uninstalling_used_extension
    index = Item.new
    index.name = 'i-am-a-new-item'
    index.extension_id = 0
    index.temp = 0
    assert index.save!
    assert_nothing_raised { index.set_content_extension(:bold) }
    assert index.has_extension?(:bold)
    
    get :uninstall, { :id => 'bold' }
    assert_rendered_file 'admin/extension/index'
    
    index.destroy
  end
  
  def test_should_remove_extension_from_database_on_uninstall
    assert_not_nil Extension.find_by_name('bold')
    get :uninstall, { :id => 'bold' }
    assert_rendered_file 'admin/extension/index'
    assert_nil Extension.find_by_name('bold')
    Extension.install('bold')
  end
  
  def test_should_show_extension_list_on_installing_nonexistent_extension
    get :install, { :id => 'i-dont-exist-hehe' }
    assert_rendered_file 'admin/extension/index'
  end
  
  def test_should_show_extension_list_on_installing_installed_extension
    assert_not_nil Extension.find_by_name('bold')
    get :install, { :id => 'bold' }
    assert_rendered_file 'admin/extension/index'
  end
  
  def test_should_install_and_list_extensions_on_no_advanced_install
    Extension.uninstall('not_installed') if Extension.exists?('not_installed')
    assert_nil Extension.find_by_name('not_installed')
    get :install, { :id => 'not_installed' }
    assert_rendered_file 'admin/extension/index'
    assert_not_nil (ext = Extension.find_by_name('not_installed'))
    assert_equal 0, ext.temp
  end
  
  def test_should_set_temp_to_0_on_finalize_call
    ext = nil
    ext = Extension.install('not_installed') unless Extension.exists?('not_installed')
    ext = Extension.find_by_name('not_installed')
    ext.temp = 1
    ext.save!
    get :finalize, { :id => 'not_installed' }
    assert_rendered_file 'admin/extension/index'
    assert_equal 0, ext.reload.temp
  end
  
  def test_should_show_extension_install_form_on_advanced_install
    Extension.uninstall('static') if Extension.exists?('static')
    assert_nil Extension.find_by_name('static')
    get :install, { :id => 'static' }
    assert_rendered_file 'admin/extension/extension'
  end
end
