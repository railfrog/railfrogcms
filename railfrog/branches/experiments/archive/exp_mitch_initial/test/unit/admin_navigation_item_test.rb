require File.dirname(__FILE__) + '/../test_helper'

class AdminNavigationItemTest < Test::Unit::TestCase
  def setup
    Locale.set('eng')
  end
  
  def assert_remove(item_name)
    assert_nothing_raised { AdminNavigationItem.unset(item_name) }
    assert_nil AdminNavigationItem.find_by_controller(item_name)
  end
  
  def test_should_enumerate_items
    enumed = {  'Items' => 'item',
                'Extensions' => 'ext',
                'Users' => 'user' }
    enumed.each { |trans,controller| assert_nothing_raised { AdminNavigationItem.set(controller,trans) } }
    assert_equal enumed, AdminNavigationItem.enumerate
    enumed.each { |trans,controller| assert_remove(controller) }
  end
  
  def test_should_translate_from_instance
    assert_nothing_raised { AdminNavigationItem.set('item', 'Items') }
    item = AdminNavigationItem.find_by_controller('item')
    assert_nothing_raised { item.set('Oooh') }
    assert_nothing_raised { item.set('yeya', 'spa') }
    assert_equal 'Oooh', item.translate
    assert_equal 'yeya', item.translate('spa')
    assert_remove('item')
  end
  
  def test_should_delete_translations_when_unsetting_item
    assert_nothing_raised { AdminNavigationItem.set('item', 'Items') }
    assert_nothing_raised { AdminNavigationItem.set('item', 'POR KAY', 'spa') }
    item = AdminNavigationItem.find_by_controller('item')
    assert_equal 2, Translation.find_all_by_tr_key(AdminNavigationItem.generate_unique_id(item.controller)).length
    assert_remove('item')
    assert_equal 0, Translation.find_all_by_tr_key(AdminNavigationItem.generate_unique_id(item.controller)).length
  end
  
  def test_should_raise_error_when_unsetting_nonexistent_item
    assert_raise(AdminNavDoesntExistException) { AdminNavigationItem.unset('lkjaslfjalsj') }
  end
  
  def test_should_set_admin_navigation_item_with_multi_languages
    assert_nothing_raised { AdminNavigationItem.set('item', 'Items') }
    assert_nothing_raised { AdminNavigationItem.set('item', 'POR KAY', 'spa') }
    assert_not_nil AdminNavigationItem.find_by_controller('item')
    assert_equal 'Items', AdminNavigationItem.translate('item')
    assert_equal 'POR KAY', AdminNavigationItem.translate('item', 'spa')
    assert_remove('item')
  end
  
  def test_should_set_admin_navigation_item_with_base_language
    assert_nothing_raised { AdminNavigationItem.set('item', 'Items') }
    assert_not_nil AdminNavigationItem.find_by_controller('item')
    assert_equal 'Items', AdminNavigationItem.translate('item')
    
    assert_nothing_raised { AdminNavigationItem.set('item', 'Edited!') }
    assert_equal 1, AdminNavigationItem.find_all_by_controller('item').length
    assert_equal 'Edited!', AdminNavigationItem.translate('item')
    
    assert_remove('item')
  end
  
  def test_should_raise_error_on_translating_non_existent_item
    assert_raise(AdminNavDoesntExistException) { AdminNavigationItem.translate('shabamdillybam') }
  end
end
