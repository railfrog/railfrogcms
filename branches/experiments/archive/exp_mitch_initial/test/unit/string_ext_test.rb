require File.dirname(__FILE__) + '/../test_helper'

class StringExtTest < Test::Unit::TestCase
  def set_locale
    assert Locale.set('eng')
  end 
  
  def test_should_return_nil_on_t_if_doesnt_exist
    assert_equal nil, 'haharhrahrhrah'.t?
    assert_equal 0, Translation.find_all_by_tr_key_and_language_id('haharhrahrhrah', Locale.language.id).length
    Locale.set_translation('hey', 'ho')
    assert_equal 'ho', 'hey'.t?
  end

  def test_should_return_default_on_non_existent_translation
    assert_equal 'I DONT EXIST I BETTER NOT NO NO NO', 'I DONT EXIST I BETTER NOT NO NO NO'._t('system')
    assert_equal 'I DONT EXIST I BETTER NOT NO NO NO', '--system-I DONT EXIST I BETTER NOT NO NO NO'.t
  end
  
  def test_should_return_translation_on_existent
    set_locale
    Locale.set_translation('--system-testing', 'Test')
    trans = 'testing'._t('system')
    assert_not_nil trans
    assert_equal 'Test', trans
  end
  
  def test_should_also_translate_by_phrase_key
    set_locale
    assert_equal 'Hello, World', 'hello_world'._t('system', 'Hello, World')
    assert_equal 'Hello, World', '--system-hello_world'.t
  end
  
  def test_should_return_translation_key_with_type
    assert_equal '--system-hey', 'hey'._tkey('system')
  end
end