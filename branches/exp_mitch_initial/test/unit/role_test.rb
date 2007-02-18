require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < Test::Unit::TestCase
  def setup
    setup_permissions
    setup_roles
  end
  
  def assert_remove(role_name)
    assert Role.remove(role_name)
    assert_nil Role.find_by_name(role_name)
  end
  
  def assert_multi_trans
    assert  Role.set('leader', 'Administrator')
    assert  Role.set('leader', 'Evil Headmaster', 'spa')
    assert_not_nil Role.find_by_name('leader')
  end
  
  def test_should_set_parent_role
    assert  Role.set('hello', 'Hello!')
    assert  Role.set_parent('hello', 'admin')
    admin = Role.find_by_name('hello')
    assert_not_nil admin
    assert_equal admin.parent_id, Role.find_by_name('admin').id
    assert_remove('hello')
  end
  
  def test_should_remove_parent_from_role
    assert  Role.set('hello', 'Hello!')
    assert  Role.set_parent('hello', 'admin')
    assert  Role.remove_parent('hello')
    admin = Role.find_by_name('hello')
    assert_not_nil admin
    assert_equal 0, admin.parent_id
    assert_remove('hello')
  end
  
  def test_should_remove_parent_from_instance
    assert  Role.set('hello', 'Hello!')
    admin = Role.find_by_name('hello')
    assert_not_nil admin
    admin.set_parent('admin')
    admin.remove_parent
    assert_equal 0, admin.parent_id
    assert_remove('hello')
  end
  
  def test_should_error_on_nonexistent_parent
    assert_raise (RoleDoesntExistException) { Role.set_parent('admin', 'idontexist') }
    admin = Role.find_by_name('admin')
    assert_not_nil admin
    assert_equal 0, admin.parent_id
  end
  
  def test_should_error_on_nonexistent_child
    assert_raise (RoleDoesntExistException) { Role.set_parent('zaboom', 'admin') }
  end
  
  def test_should_set_parent_from_instance
    assert  Role.set('hello', 'Hello!')
    admin = Role.find_by_name('hello')
    assert_not_nil admin
    admin.set_parent('admin')
    assert_equal admin.parent_id, Role.find_by_name('admin').id
    assert_remove('hello')
  end
  
  def test_should_role_should_be_unique
    assert  Role.set('leader', 'Administrator')
    assert  Role.set('leader', 'Some other title')
    assert_equal 1, Role.find_all_by_name('leader').length
    assert_remove('leader')
  end

  def test_should_create_and_remove_role
    assert  Role.set('leader', 'Administrator')
    assert_not_nil Role.find_by_name('leader')
    assert_remove 'leader'
  end
  
  def test_should_create_role_with_translation
    assert  Role.set('leader', 'Administrator')
    assert_not_nil Role.find_by_name('leader')
    assert_equal 'Administrator', Role.translate('leader')
    assert_remove 'leader'
  end
  
  def test_should_create_role_with_multiple_translations
    assert  Role.set('leader', 'Administrator')
    assert  Role.set('leader', 'Evil Headmaster', 'spa')
    assert_not_nil Role.find_by_name('leader')
    assert_equal 'Administrator', Role.translate('leader')
    assert_equal 'Evil Headmaster', Role.translate('leader', 'spa')
    assert_remove 'leader'
  end
  
  def test_should_cleanup_translations_on_role_removal
    assert  Role.set('leader', 'Administrator')
    assert  Role.set('leader', 'Evil Headmaster', 'spa')
    assert_not_nil Role.find_by_name('leader')
    assert_remove 'leader'
    assert_equal 0, Translation.find_all_by_tr_key(Role.generate_unique_id('leader')).length
  end
  
  def test_should_cleanup_role_permissions_on_role_removal
    assert Role.set('leader', 'Administrator')
    assert Role.set_permission(:leader, :basic_create, 1)
    assert Role.set_permission(:leader, :basic_delete, 1)
    leader = Role.find_by_name('leader')
    assert_equal 2, RolePermission.find_all_by_role_id(leader.id).length
    assert leader.destroy
    assert_equal 0, RolePermission.find_all_by_role_id(leader.id).length
  end
  
  def test_should_translate_from_instance_too
    assert  Role.set('leader', 'Administrator')
    assert  Role.set('leader', 'Evil Headmaster', 'spa')
    admin = Role.find_by_name('leader')
    assert_not_nil admin
    assert_equal 'Administrator', admin.translate
    assert_equal 'Evil Headmaster', admin.translate('spa')
    assert_remove 'leader'
  end
  
  def test_should_set_translation_from_instance_too
    assert  Role.set('leader', 'Administrator')
    admin = Role.find_by_name('leader')
    assert_not_nil admin
    assert admin.set('Evil Headmaster', 'spa')
    assert admin.set('RAWR')
    assert_equal 'Evil Headmaster', admin.translate('spa')
    assert_equal 'RAWR', admin.translate
    assert_remove 'leader'
  end
  
  def test_should_add_permissions_to_role
    assert  Role.set_permission('admin', 'basic_create', 1)
    assert  Role.has_permission?('admin', 'basic_create')
    assert  Role.set_permission('admin', 'basic_create', 0)
    assert_equal false, Role.has_permission?('admin', 'basic_create')
  end
  
  def test_should_inhert_permissions_from_parent
    assert Role.set_permission('parent', 'basic_create', 1)
    assert Role.set_permission('child', 'basic_delete', 1)
    assert Role.set_permission('child', 'basic_create')
    assert Role.remove_parent('child')
    
    assert Role.has_permission?(:child, :basic_delete)
    assert_equal false, Role.has_permission?(:child, :basic_create)
    
    assert Role.set_parent('child', 'parent')
    assert Role.has_permission?(:child, :basic_create)
    assert_equal false, Role.has_permission?(:child, :basic_create, true)
  end
  
  def test_should_add_permissions_to_role_instance
    admin = Role.find_by_name('admin')
    assert_not_nil admin
    assert admin.set_permission('basic_create', 1)
    assert admin.has_permission?('basic_create')
    assert admin.set_permission('basic_create', 0)
    assert_equal false, admin.has_permission?('basic_create')
  end
  
  def test_should_not_have_permission_when_non_existent
    assert_equal false, Role.has_permission?('admin', 'basic_doesnt_exist')
  end
  
  def test_should_associate_with_permissions
    admin = Role.find_by_name('admin', :include => :role_permissions)
    assert_not_nil admin
    
    admin.set_permission('basic_create', 1)
    admin.set_permission('basic_delete')
    assert_not_nil admin.role_permissions
    admin.role_permissions.each do |perm|
      assert_equal perm.value == 1, admin.has_permission?(perm.name)
    end
  end
  
  def test_should_set_single_default_role
    assert Role.set_default('admin')
    assert_equal 1, Role.find_all_by_is_default(1).length
    assert_equal 'admin', Role.find_by_is_default(1).name
    assert Role.set_default('parent')
    assert_equal 1, Role.find_all_by_is_default(1).length
    assert_equal 'parent', Role.find_by_is_default(1).name
  end
  
  def test_should_set_default_role_from_instance
    admin = Role.find_by_name('admin')
    assert_not_nil admin
    assert admin.set_default
    assert_equal 1, Role.find_all_by_is_default(1).length
    assert_equal 'admin', Role.find_by_is_default(1).name
  end
  
  def test_should_return_default_role
    assert Role.set_default('admin')
    assert_equal 'admin', Role.default.name
  end
  
  def test_should_remove_translation_by_language
    Locale.set('eng')
    assert Role.set('guy', 'Guy')
    assert Role.set('guy', 'Boy', 'spa')
    assert_equal 'Guy', Role.translate('guy')
    assert_equal 'Boy', Role.translate('guy', 'spa')
    assert_nothing_raised { Role.remove_translation('guy', 'spa') }
    perm = Role.find_by_name('guy')
    lang = Language.find_by_iso_639_2('spa')
    assert_equal nil, Translation.find_by_tr_key_and_language_id(Role.generate_unique_id(perm.id), lang.id)
  end
  
  def test_should_remove_translation_by_language_from_instance
    Locale.set('eng')
    assert Role.set('guy', 'Guy')
    role = Role.find_by_name('guy')
    assert role.set('Boy', 'spa')
    assert_equal 'Guy', role.translate
    assert_equal 'Boy', role.translate('spa')
    assert_nothing_raised { role.remove_translation('spa') }
    lang = Language.find_by_iso_639_2('spa')
    assert_equal nil, Translation.find_by_tr_key_and_language_id(Role.generate_unique_id(role.id), lang.id)
  end
end
