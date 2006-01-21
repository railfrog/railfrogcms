require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/role_controller'

# Re-raise errors caught by the controller.
class Admin::RoleController; def rescue_action(e) raise e end; end

class Admin::RoleControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::RoleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_list_roles_on_index
    get :index
    assert_rendered_file 'admin/role/index'
    assert assigns.has_key?('roles')
  end
  
  def test_should_set_and_remove_parents_from_roles
    assert Role.set('test4', 'addparents')
    assert Role.set('testParent', 'theparent')
    role = Role.find_by_name('test4')
    parent = Role.find_by_name('testParent')
    
    assert role.parent.nil?
    post :edit_parent, { :id => role.id, :editrole => { :parent_id => parent.id } }
    role.reload
    assert_equal false, role.parent.nil?
    assert_equal parent.id, role.parent.id
    
    post :edit_parent, { :id => role.id, :editrole => { :parent_id => '' } }
    role.reload
    assert role.parent.nil?
  end
  
  def test_should_list_parents_and_not_include_role_being_edited
    assert Role.set('test3', 'testmeout')
    role = Role.find_by_name('test3')
    
    get :edit_language, { :id => role.id }
    assert assigns.has_key?('parents')
    assert_nil assigns['parents'].detect { |p| p[1] == role.id }
  end
  
  def test_should_list_languages_for_roles
    assert Role.set('test', 'hoorah')
    role = Role.find_by_name('test')
    
    get :edit_language, { :id => role.id }
    assert_rendered_file 'admin/role/edit_language'
    assert assigns.has_key?('languages')
    assert assigns.has_key?('editrole')
    assert_equal 1, assigns['languages'].length
    
    assert role.set('rawr', 'spa')
    get :edit_language, { :id => role.id }
    assert_rendered_file 'admin/role/edit_language'
    assert assigns.has_key?('languages')
    assert assigns.has_key?('editrole')
    assert_equal 2, assigns['languages'].length
  end

  def test_should_edit_translation
    assert Role.set('test2', 'hi')
    role = Role.find_by_name('test2')
    assert_equal 'hi', role.translate
    
    post :do_edit, { :id => role.id, :editlang => 'eng', :editrole => { :name => 'ho' } }
    assert_rendered_file 'admin/role/edit_language'
    assert_equal 'ho', role.translate
    
    post :do_edit_with_ajax, { :id => role.id, :editlang => 'eng', :editrole => { :name => 'hey' } }
    assert_rendered_file 'admin/role/edit_language'
    assert_equal 'hey', role.translate
  end

  def test_should_remove_translation
    assert Role.set('test3', 'hi')
    role = Role.find_by_name('test3')
    assert_equal 'hi', role.translate
    
    post :do_edit, { :id => role.id, :editlang => 'spa', :editrole => { :name => 'ho' } }
    assert_rendered_file 'admin/role/edit_language'
    assert_equal 2, assigns['languages'].length
    assert_equal 'ho', role.translate('spa')
    
    get :destroy_translation, { :id => role.id, :editlang => 'spa' }
    assert_rendered_file 'admin/role/edit_language'
    assert_equal 1, assigns['languages'].length
  end
  
  def test_should_list_permissions_and_values
    assert Role.set('test-perms', 'Bla')
    assert Permission.set('has_a_foot', 'Has a foot')
    assert_equal false, Role.has_permission?('test-perms', :has_a_foot)
    
    role = Role.find_by_name('test-perms')
    perm = Permission.find_by_name('has_a_foot')
    
    get :permissions, { :id => role.id }
    assert_rendered_file 'admin/role/permissions'
    assert assigns.has_key?('permissions')
    
    post :do_permissions, { :id => role.id, 'permission_' + perm.id.to_s => '1' }
    assert_rendered_file 'admin/role/index'
    assert Role.has_permission?('test-perms', :has_a_foot)
  end
end
