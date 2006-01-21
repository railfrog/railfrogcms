require File.dirname(__FILE__) + '/../test_helper'

class PermissionTest < Test::Unit::TestCase
  def setup
    setup_roles
    setup_permissions
  end

  def assert_remove(perm_name)
    assert Permission.remove(perm_name)
    assert_nil Permission.find_by_name(perm_name)
  end
  
  def test_should_remote_all_translations_on_permission_removal
    Locale.set('eng')
    assert Permission.set('create_item', 'Create Item')
    assert Permission.set('create_item', 'Item Create', 'spa')
    perm = Permission.find_by_name('create_item')
    assert_equal 2, Translation.find_all_by_tr_key(Permission.generate_unique_id(perm.id)).length
    assert_remove 'create_item'
    assert_equal 0, Translation.find_all_by_tr_key(Permission.generate_unique_id(perm.id)).length
  end
  
  def test_should_remove_all_role_permissions_on_permission_removal
    assert Role.set('rawr', 'Rawr')
    assert Permission.set('rawr_perm', 'Permission to Rawr')
    assert Role.set_permission(:rawr, :rawr_perm, 1)
    assert Role.has_permission?(:rawr, :rawr_perm)
    rawr = Permission.find_by_name('rawr_perm')
    assert_not_nil rawr
    assert rawr.destroy
    assert_equal false, Role.has_permission?(:rawr, :rawr_perm)
    assert_equal 0, RolePermission.find_all_by_permission_id(rawr.id).length
  end

  def test_should_create_permission_with_base_language
    assert Permission.set('create_item', 'Create Item')
    assert_not_nil Permission.find_by_name('create_item')
    assert_equal 'Create Item', Permission.translate('create_item')
    assert_remove('create_item')
  end
  
  def test_should_create_permission_with_multi_translations
    Locale.set('eng')
    assert Permission.set('create_item', 'Create Item')
    assert Permission.set('create_item', 'Item Create', 'spa')
    
    assert_equal 'Create Item', Permission.translate('create_item')
    assert_equal 'Item Create', Permission.translate('create_item', 'spa')
    assert_remove 'create_item'
  end
  
  def test_should_translate_from_class_instance
    Locale.set('eng')
    assert Permission.set('create_item', 'Create Item')
    perm = Permission.find_by_name('create_item')
    assert_not_nil perm
    assert perm.set('Item Create', 'spa')
    
    assert_equal 'Create Item', perm.translate
    assert_equal 'Item Create', perm.translate('spa')
    assert_remove 'create_item'
  end
  
  def test_should_create_one_entry_per_permission_name
    assert Permission.set('create_item', 'Create Item')
    assert Permission.set('create_item', 'new translation')
    
    assert_equal 1, Permission.find_all_by_name('create_item').length
    assert_remove 'create_item'
  end
  
  def test_should_remove_all_translations_on_destroy
    Locale.set('eng')
    assert Permission.set('create_item', 'Create Item')
    perm = Permission.find_by_name('create_item')
    assert_not_nil perm
    assert_remove 'create_item'
    assert_equal 0, Translation.find_all_by_tr_key(Permission.generate_unique_id('create_item')).length
  end
  
  def test_should_raise_error_on_removing_translation_with_bad_params
    Locale.set('eng')
    assert Permission.set('test-error', 'Test Lang')
    assert_raise(PermDoesntExistException) { Permission.remove_translation('blabalabal', 'eng') }
    assert_raise(PermOnlyHasOneTranslationException) { Permission.remove_translation('test-error', 'eng') }
    assert Permission.set('test-error', 'blabla', 'spa')
    assert_raise(PermDoesntExistException) { Permission.remove_translation('test-error', 'mra') }
    assert_raise(LangDoesntExistException) { Permission.remove_translation('test-error', 'bea') }
  end
  
  def test_should_remove_translation_by_language
    Locale.set('eng')
    assert Permission.set('remove_lang', 'Remove Lang')
    assert Permission.set('remove_lang', 'Bla bla', 'spa')
    assert_equal 'Remove Lang', Permission.translate('remove_lang')
    assert_equal 'Bla bla', Permission.translate('remove_lang', 'spa')
    assert_nothing_raised { Permission.remove_translation('remove_lang', 'spa') }
    perm = Permission.find_by_name('remove_lang')
    lang = Language.find_by_iso_639_2('spa')
    assert_equal nil, Translation.find_by_tr_key_and_language_id(Permission.generate_unique_id(perm.id), lang.id)
  end
  
  def test_should_remove_translation_by_language_from_instance
    Locale.set('eng')
    assert Permission.set('remove_lang', 'Remove Lang')
    perm = Permission.find_by_name('remove_lang')
    assert perm.set('Bla bla', 'spa')
    assert_equal 'Remove Lang', perm.translate
    assert_equal 'Bla bla', perm.translate('spa')
    assert_nothing_raised { perm.remove_translation('spa') }
    lang = Language.find_by_iso_639_2('spa')
    assert_equal nil, Translation.find_by_tr_key_and_language_id(Permission.generate_unique_id(perm.id), lang.id)
  end
end
