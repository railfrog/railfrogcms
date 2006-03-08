require File.dirname(__FILE__) + '/../test_helper'

class RolePermissionTest < Test::Unit::TestCase
  def setup
    setup_permissions
    setup_roles
  end
  
  def assert_remove(role, perm)
    assert RolePermission.remove(role, perm)
  end
  
  def test_should_inherit_permissions_from_parent
    assert RolePermission.set('parent', 'basic_create', 1)
    assert RolePermission.set('child', 'basic_delete', 1)
    assert RolePermission.set('child', 'basic_create')
    assert Role.remove_parent('child')
    
    assert_equal 1, RolePermission.check(:child, :basic_delete)
    assert_equal 0, RolePermission.check(:child, :basic_create)
    
    assert Role.set_parent('child', 'parent')
    assert_equal 1, RolePermission.check(:child, :basic_create)
    assert_equal 0, RolePermission.check(:child, :basic_create, true)
    
    assert Role.set('newb', 'Newbie')
    assert Role.set_parent('newb', 'parent')
    assert_equal 1, RolePermission.check(:newb, :basic_create)
  end
  
  def test_should_error_on_non_existent_role
    assert_raise (RoleDoesntExistException) { RolePermission.set('adminaaa', 'basic_create', 1) }
    assert_raise (RoleDoesntExistException) { RolePermission.set(:i_dont_exist, 'basic_create', 1) }
    assert_raise (RoleDoesntExistException) { RolePermission.set({'it' => 'cannot handle this'}, 'basic_create', 1) }
  end
  
  def test_should_error_on_non_existent_perm
    assert_raise (PermDoesntExistException) { RolePermission.set('admin', 'basic...what?') }
    assert_raise (PermDoesntExistException) { RolePermission.set('admin', {'rawr' => 'yeaaaa'}) }
    assert_raise (PermDoesntExistException) { RolePermission.set('admin', :i_dont_exist) }
  end
  
  def test_should_create_role_permission_from_instances
    role = Role.find_by_name('admin')
    perm = Permission.find_by_name('basic_create')
    assert RolePermission.set(role, perm)
    assert_not_nil RolePermission.find_by_role_id_and_permission_id(role.id, perm.id)
    assert_remove('admin', 'basic_create')
  end
  
  def test_should_create_role_from_strings
    role = Role.find_by_name('admin')
    perm = Permission.find_by_name('basic_create')
    assert RolePermission.set('admin', 'basic_create')
    assert_not_nil RolePermission.find_by_role_id_and_permission_id(role.id, perm.id)
    assert_remove('admin', 'basic_create')
  end
  
  def test_should_create_role_from_symbols
    role = Role.find_by_name('admin')
    perm = Permission.find_by_name('basic_create')
    assert RolePermission.set(:admin, :basic_create)
    assert_not_nil RolePermission.find_by_role_id_and_permission_id(role.id, perm.id)
    assert_remove('admin', 'basic_create')
  end
  
  def test_should_create_unique_per_role_and_permission
    role = Role.find_by_name('admin')
    perm = Permission.find_by_name('basic_create')
    assert RolePermission.set(:admin, :basic_create)
    assert RolePermission.set(:admin, :basic_create, 1)
    assert_equal 1, RolePermission.find_all_by_role_id_and_permission_id(role.id, perm.id).length
    assert_remove('admin', 'basic_create')
  end
  
  def test_should_edit_role_when_resetting
    role = Role.find_by_name('admin')
    perm = Permission.find_by_name('basic_create')
    assert RolePermission.set(:admin, :basic_create)
    assert_equal 0, RolePermission.check(:admin, :basic_create)
    assert RolePermission.set(:admin, :basic_create, 1)
    assert_equal 1, RolePermission.check(:admin, :basic_create)
    assert_remove('admin', 'basic_create')
  end
  
  def test_should_check_strings_symbols_and_instances
    role = Role.find_by_name('admin')
    assert_not_nil role
    perm = Permission.find_by_name('basic_create')
    assert_not_nil perm 
    assert RolePermission.set(:admin, :basic_create)
    assert_equal 0, RolePermission.check(:admin, :basic_create)
    assert_equal 0, RolePermission.check('admin', 'basic_create')
    assert_equal 0, RolePermission.check(role, perm)
    assert_remove('admin', 'basic_create')
  end
  
  def test_should_remove_from_strings_symbols_and_instances
    role = Role.find_by_name('admin')
    perm = Permission.find_by_name('basic_create')
    assert RolePermission.set(:admin, :basic_create)
    assert_not_nil RolePermission.find_by_role_id_and_permission_id(role.id, perm.id)
    assert_remove('admin', 'basic_create')
    
    assert RolePermission.set(:admin, :basic_create)
    assert_not_nil RolePermission.find_by_role_id_and_permission_id(role.id, perm.id)
    assert_remove(:admin, :basic_create)
    
    assert RolePermission.set(:admin, :basic_create)
    assert_not_nil RolePermission.find_by_role_id_and_permission_id(role.id, perm.id)
    assert_remove(role, perm)
  end
  
  def test_should_return_permission_name_from_instance_method_name
    role = Role.find_by_name('admin')
    perm = Permission.find_by_name('basic_create')
    assert RolePermission.set(:admin, :basic_create)
    rp = RolePermission.get_rp_from_params(role, perm)
    assert_equal 'basic_create', rp.name
    assert_remove('admin', 'basic_create')
  end
  
  def test_should_remove_all_role_permissions_from_role
    assert RolePermission.set(:admin, :basic_create, 1)
    assert RolePermission.set(:admin, :basic_delete, 1)
    admin = Role.find_by_name('admin')
    assert_equal 2, RolePermission.find_all_by_role_id(admin.id).length
    assert RolePermission.remove_all(:admin)
    assert_equal 0, RolePermission.find_all_by_role_id(admin.id).length
  end
end
