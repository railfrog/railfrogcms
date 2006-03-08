require File.dirname(__FILE__) + '/../test_helper'

class CharacteristicTest < Test::Unit::TestCase
  fixtures :characteristics, :items
  
  def setup
    Locale.set('eng')
  end
  
  def test_should_add_multiple_characteristics_to_an_item_and_retrieve_them
    assert Characteristic.set(items(:item1).id, 'test', 'value')
    
    item1 = Item.find(items(:item1).id, :include => :characteristics)
    assert_not_nil item1['test']
    assert_equal 'value', item1['test']
    
    assert Characteristic.set(items(:item1).name, 'test2', 'value')
    assert_not_nil item1['test2']
    assert_equal 'value', item1['test2']
  end
  
  def test_should_remove_charactertics_and_no_longer_find_them
    assert Characteristic.set(items(:item1).id, 'test3', 'value')
    assert Characteristic.remove(items(:item1).id, 'test3')
    assert_nil Characteristic.find_by_item_id_and_name(items(:item1).id, 'test3')
    assert_equal 0, Translation.find_all_by_tr_key(Characteristic.generate_unique_id(items(:item1).id, 'test3')).length
  end
  
  def test_should_have_only_one_characteristic_with_same_name
    assert Characteristic.set(items(:item1).id, 'test4', 'value')
    assert Characteristic.set(items(:item1).id, 'test4', 'newvalue')
    assert_equal 1, Characteristic.find_all_by_item_id_and_name(items(:item1).id, 'test4').length
  end
  
  def test_should_save_multiple_translations_and_retrieve_them_in_the_correct_language
    assert Characteristic.set(items(:item1).id, 'test5', 'value')
    assert Characteristic.set(items(:item1).id, 'test5', 'foo!!', 'spa')

    item1 = Item.find(items(:item1).id, :include => :characteristics)
    assert_equal 'value', item1['test5']
    Locale.swap('spa') { assert_equal 'foo!!', item1['test5'] }
  end
  
  def test_should_return_nil_on_retrieving_nonexistent_translation
    assert Characteristic.set(items(:item1).id, 'test6', 'value')
    item1 = Item.find(items(:item1).id, :include => :characteristics)
    assert_equal 'value', item1['test6']
    Locale.swap('spa') { assert_equal nil, item1['test6'] }
  end
end
