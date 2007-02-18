require File.dirname(__FILE__) + '/../test_helper'

class OptionTest < Test::Unit::TestCase
  fixtures :options

  def test_should_get_option_through_get_method
    assert_equal Option.get('index'), options(:index).value
  end
  
  def test_should_return_nil_on_non_existent_option
    assert_nil Option.get('non-existent')
  end
  
  def test_should_set_option_through_set_method_and_return_it
    assert Option.set('foo', 'bar')
    assert_equal Option.get('foo'), 'bar'
  end
  
  def test_should_remove_option_through_remove_method_and_return_nil_on_get
    assert Option.set('test', 'thebest')
    assert Option.remove('test')
    assert_nil Option.get('test')
  end
  
  def test_should_only_set_one_value_per_option_name
    assert Option.set('pie', 'is good')
    assert Option.set('pie', 'crust is the best')
    assert_equal 1, Option.find_all_by_name('pie').length
  end
end
