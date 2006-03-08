require File.dirname(__FILE__) + '/../test_helper'

class ItemExtensionTest < Test::Unit::TestCase
  def setup
    setup_permissions
    set_good_extension_path
    Extension.install('static') unless Extension.exists?('static')
    Extension.install('not_installed') unless Extension.exists?('not_installed')
    Extension.install('bold') unless Extension.exists?('bold')
    
    item = Item.new
    item.name = 'fake-item'
    item.extension_id = Extension.find_by_name('static').id
    assert_nothing_raised { item.save! }
  end
  
  def teardown
    item = Item.find_by_name('fake-item')
    item.destroy
  end
  
  def test_should_check_if_item_has_content_extension
    assert_nothing_raised { ItemExtension.set('fake-item', :bold) }
    assert ItemExtension.has?('fake-item', :bold)
    assert_nothing_raised { ItemExtension.unset('fake-item', :bold) }
    assert_equal false, ItemExtension.has?('fake-item', :bold)
  end
  
  def test_should_associate_extension_with_item_with_string_symbol_and_instance
    item = Item.find_by_name('fake-item')
    bold = Extension.find_by_name('bold')
    assert_nothing_raised { ItemExtension.set(item, bold) }
    assert_not_nil ItemExtension.find_by_item_id_and_extension_id(item.id, bold.id)
    assert_nothing_raised { ItemExtension.unset(item, bold) }
    
    assert_nothing_raised { ItemExtension.set('fake-item', 'bold') }
    assert_not_nil ItemExtension.find_by_item_id_and_extension_id(item.id, bold.id)
    assert_nothing_raised { ItemExtension.unset(item, bold) }
    
    assert_nothing_raised { ItemExtension.set(item, :bold) }
    assert_not_nil ItemExtension.find_by_item_id_and_extension_id(item.id, bold.id)
    assert_nothing_raised { ItemExtension.unset(item, bold) }
  end
  
  def test_should_remove_extension_associate_from_item
    item = Item.find_by_name('fake-item')
    bold = Extension.find_by_name('bold')
    assert_nothing_raised { ItemExtension.set(item, bold) }
    assert_not_nil ItemExtension.find_by_item_id_and_extension_id(item.id, bold.id)
    assert_nothing_raised { ItemExtension.unset(item, bold) }
    assert_nil ItemExtension.find_by_item_id_and_extension_id(item.id, bold.id)
  end

  def test_should_call_extension_methods_from_instance
    item = Item.find_by_name('fake-item')
    bold = Extension.find_by_name('bold')
    assert_nothing_raised { ItemExtension.set(item, bold) }
    assert_not_nil (ie = ItemExtension.find_by_item_id_and_extension_id(item.id, bold.id))
    assert_equal 'Hi', ie.ext_say_hi
    assert_nothing_raised { ItemExtension.unset(item, bold) }
  end
  
  def test_should_associate_with_item_and_extension
    item = Item.find_by_name('fake-item')
    bold = Extension.find_by_name('bold')
    assert_nothing_raised { ItemExtension.set(item, bold) }
    assert_not_nil (ie = ItemExtension.find_by_item_id_and_extension_id(item.id, bold.id))
    assert_not_nil ie.item
    assert_not_nil ie.extension
    assert_equal 'fake-item', ie.item.name
    assert_equal 'bold', ie.extension.name
    assert_nothing_raised { ItemExtension.unset(item, bold) }
  end
end
