require File.dirname(__FILE__) + '/../test_helper'

class ThemeLibTest < Test::Unit::TestCase
  def setup
    set_good_theme_path
    set_fake_renderer
  end
  
  def test_should_error_on_bad_renderer
    assert_equal false, Theme::set_renderer('nono')
  end
  
  def test_should_error_on_nonexistent_path
    assert_equal false, Theme::set_path('/this/is/my/someplace/that/doesnt/exist')
  end
  
  def test_should_set_existent_theme
    assert Theme::set('system')
    assert_equal 'system', Theme::current
  end
  
  def test_should_not_set_nonexistent_theme
    assert_equal false, Theme::set('asfjkklajlajdfkla')
  end
  
  def test_should_render_from_correct_file
    assert Theme::set('system')
    assert_equal 'BOO!', Theme::render('boo')
  end
  
  def test_should_not_render_when_no_file_exists
    assert_equal false, Theme::render('hehe_i_dont_exist')
  end
  
  def test_should_assign_variable_for_template
    assert Theme::assign('test', 'hello')
    assert Theme::get_assigns.has_key?('test')
    assert Theme::get_assigns.has_value?('hello')
  end
  
  def test_should_assign_instance_variables_from_object
    @instance_one = 'yay'
    @instance_two = 'oh'
    assert Theme::assign(self)
    assert Theme::get_assigns.has_key?('instance_one')
    assert_equal 'yay', Theme::get_assigns['instance_one']
    assert Theme::get_assigns.has_key?('instance_two')
    assert_equal 'oh', Theme::get_assigns['instance_two']
  end
  
  def test_should_replace_assigns_in_renderer_class
    @test = 'woohoo'
    assert Theme::assign(self)
    @test = nil
    assert_nil @test
    assert Theme::put_assigns_into(self)
    assert_equal 'woohoo', @test
  end
  
  def test_should_render_theme_files_in_extension_dir_for_extensions
    Theme::extension('static') do
      assert Theme::render('test')
      assert_equal 'hi', Theme::extension_contents
    end
  end
  
  def test_should_render_theme_files_in_theme_dir_for_extensions_with_options
    Theme::extension('static') do
      assert Theme::render('test_in_theme', :string => false)
      assert_equal 'hey', Theme::extension_contents
    end
  end

  def test_should_render_theme_files_in_theme_dir_for_extensions
    Theme::extension('static') do
      assert Theme::render('test_in_theme')
      assert_equal 'hey', Theme::extension_contents
    end
  end
  
  def test_should_also_return_values_for_extensions
    Theme::extension('static') do
      assert_equal 'hey', Theme::render('test_in_theme', :string => true)
    end
  end
  
  def test_should_render_string
    assert_equal 'yo', Theme::render_string('yo')
  end
  
  def test_should_render_string_for_extensions
    Theme::extension('static') do
      assert_equal 'yo', Theme::render_string('yo', :string => true)
      assert Theme::extension_contents.empty?
    end
  end
  
  def test_should_swap_templates_for_block
    assert_equal 'system', Theme::current
    assert_equal 'BOO!', Theme::render('boo', :string => true)
    Theme::swap('dummy') do
      assert_equal 'dummy', Theme::current
      assert_equal 'BOO! from Dummy', Theme::render('boo', :string => true)
    end
    assert_equal 'system', Theme::current
  end
end