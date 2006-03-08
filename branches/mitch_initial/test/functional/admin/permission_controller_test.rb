require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/permission_controller'

# Re-raise errors caught by the controller.
class Admin::PermissionController; def rescue_action(e) raise e end; end

class Admin::PermissionControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::PermissionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_set_permissions_array_on_index
    get :index
    assert_not_nil assigns['permissions']
  end
  
  def test_should_list_languages_for_permissions
    assert Permission.set('test', 'hoorah')
    perm = Permission.find_by_name('test')
    
    get :edit_language, { :id => perm.id }
    assert_rendered_file 'admin/permission/edit_language'
    assert assigns.has_key?('languages')
    assert assigns.has_key?('editperm')
    assert_equal 1, assigns['languages'].length
    
    assert perm.set('rawr', 'spa')
    get :edit_language, { :id => perm.id }
    assert_rendered_file 'admin/permission/edit_language'
    assert assigns.has_key?('languages')
    assert assigns.has_key?('editperm')
    assert_equal 2, assigns['languages'].length
  end
  
  def test_should_edit_translation
    assert Permission.set('test2', 'hi')
    perm = Permission.find_by_name('test2')
    assert_equal 'hi', perm.translate
    
    post :do_edit, { :id => perm.id, :editlang => 'eng', :editperm => { :name => 'ho' } }
    assert_rendered_file 'admin/permission/edit_language'
    assert_equal 'ho', perm.translate
    
    post :do_edit_with_ajax, { :id => perm.id, :editlang => 'eng', :editperm => { :name => 'hey' } }
    assert_rendered_file 'admin/permission/edit_language'
    assert_equal 'hey', perm.translate
  end
  
  def test_should_remove_translation
    assert Permission.set('test3', 'hi')
    perm = Permission.find_by_name('test3')
    assert_equal 'hi', perm.translate
    
    post :do_edit, { :id => perm.id, :editlang => 'spa', :editperm => { :name => 'ho' } }
    assert_rendered_file 'admin/permission/edit_language'
    assert_equal 2, assigns['languages'].length
    assert_equal 'ho', perm.translate('spa')
    
    get :destroy_translation, { :id => perm.id, :editlang => 'spa' }
    assert_rendered_file 'admin/permission/edit_language'
    assert_equal 1, assigns['languages'].length
  end
end
