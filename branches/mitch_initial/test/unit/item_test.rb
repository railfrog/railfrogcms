require File.dirname(__FILE__) + '/../test_helper'

class ItemTest < Test::Unit::TestCase
  fixtures :items, :characteristics, :extensions

  def install_ext
    set_good_extension_path
    Extension.install('bold') unless Extension.exists?('bold')
    Locale.set('eng')
  end

  def test_should_succesfully_create_new_item
    index = Item.new
    index.name = 'i-am-a-new-item'
    index.extension_id = 1
    index.temp = 0
    assert index.save!
    
    assert_not_nil Item.find_by_name('i-am-a-new-item')
  end
  
  def test_should_set_temp_to_0_on_finalize
    index = Item.new
    index.name = 'blablabla'
    index.extension_id = 1
    index.temp = 1
    assert index.save!
    index.finalize
    assert_equal 0, Item.find_by_id(index.id).temp
  end
  
  def test_should_run_content_extensions_on_item
    index = Item.new
    index.name = 'process-my-exts'
    index.extension_id = 1
    index.temp = 1
    assert index.save!
    assert_nothing_raised { index.set_content_extension(:bold) }
    assert_equal '<b>test</b>', index.run_content('test')
  end
  
  def test_should_delete_extension_associations_and_characteristics_on_destroy
    install_ext
    
    index = Item.new
    index.name = 'associate-me-and-destroy'
    index.extension_id = 1
    index.temp = 1
    assert index.save!
    assert_nothing_raised { index.set_content_extension(:bold) }
    assert_equal 1, index.item_extensions.count
    index['test'] = 'yay'
    assert_equal 'yay', index['test']
    index.destroy
    assert_equal 0, ItemExtension.find_all_by_item_id(index.id).length
    assert_equal 0, Characteristic.find_all_by_item_id(index.id).length
  end
  
  def test_should_associate_with_content_extensions
    install_ext
    
    index = Item.new
    index.name = 'associate-me'
    index.extension_id = 1
    index.temp = 1
    assert index.save!
    assert_nothing_raised { index.set_content_extension(:bold) }
    assert_equal 1, index.item_extensions.count
    assert_nothing_raised { index.unset_content_extension(:bold) }
    assert_equal 0, index.item_extensions.count
  end
  
  def test_should_check_if_item_has_extensions
    install_ext
    
    index = Item.new
    index.name = 'check-me-out'
    index.extension_id = 1
    index.temp = 1
    assert index.save!
    assert_nothing_raised { index.set_content_extension(:bold) }
    assert index.has_extension?(:bold)
    assert_nothing_raised { index.unset_content_extension(:bold) }
    assert_equal false, index.has_extension?(:bold)
  end
  
  def test_should_find_items_successfully
    assert_equal items(:item1), Item.find_by_name('item-one')
    assert_equal items(:item1), Item.find(1)
  end
  
  def test_should_set_characteristics_through_item_and_read_them
    item_one = items(:item1)
    item_one['test1'] = 'value'
    
    assert_not_nil item_one['test1']
    assert_equal 'value', item_one['test1']
    
    item_one['test1'] = 'value2'
    assert_equal 'value2', item_one['test1']
  end
  
  def test_should_remove_characteristics_through_item
    item_one = items(:item1)
    item_one['test2'] = 'oh'
    assert_not_nil item_one['test2']
    
    item_one.remove_characteristic('test2')
    assert_nil item_one['test2']
  end
  
  def test_should_set_characteristics_in_multiple_languages
    item_one = items(:item1)
    item_one['test'] = 'English'
    Locale.set('spa')
    item_one['test'] = 'Spanish'
    Locale.set('eng')
    assert_equal 'English', item_one['test']
    Locale.set('spa')
    assert_equal 'Spanish', item_one['test']
    Locale.set('eng')
  end
  
  def test_should_return_nil_on_untranslated_characteristic
    item_one = items(:item1)
    Locale.set('eng')
    item_one['heyo'] = 'hiyo'
    assert_equal 'hiyo', item_one['heyo']
    Locale.set('spa')
    assert_equal nil, item_one['heyo']
    Locale.set('eng')
  end
  
  def test_should_load_item_through_extension_model_and_run_extension_methods
    item_one = Item.find(items(:item1).id, :include => :extension)
    assert_equal item_one.extension.name, 'static'
    assert_equal 'StaticExt', item_one.extklass.class.to_s
    assert_equal 'Pass', item_one.extklass.test_pass
    assert_equal 'Pass', item_one.ext_test_pass
    assert item_one.has_extension?('static')
    assert_raise(NoMethodError) { item_one.ext_weeeee }
  end
end
