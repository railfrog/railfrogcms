require File.dirname(__FILE__) + '/../test_helper'

class ExtensionTest < Test::Unit::TestCase
  fixtures :extensions
  
  def setup
    set_good_extension_path
    set_fake_renderer
  end
  
  def install_not_installed
    assert extension = Extension.install('not_installed')
    assert_kind_of Extension, extension
  end
  
  def uninstall_not_installed
    assert Extension.uninstall('not_installed')
  end
  
  def test_should_set_temp_to_zero_on_finalize
    Extension.uninstall('static') if Extension.exists?('static')
    Extension.install('static')
    static = Extension.find_by_name('static')
    assert_equal 1, static.temp
    assert static.finalize
    assert_equal 0, static.temp
  end
  
  def test_should_load_yaml_data_from_instance
    Extension.install('static') unless Extension.exists?('static')
    static = Extension.find_by_name('static')
    assert_equal 'Static', static.info['name']
    assert_equal 'static text', static.info['desc']
    
    Extension.install('bold') unless Extension.exists?('bold')
    bold = Extension.find_by_name('bold')
    assert_equal 'bold', bold.info['name']
  end
  
  def test_should_put_question_mark_and_blank_for_unknown_yaml_data
    should_be = { 'name' => '', 'desc' => '', 'raw_name' => 'bold' }
    assert_equal should_be, Extension.load_yaml_data('bold')
  end
  
  def test_should_load_good_yaml_data_from_extension
    should_be = { 'name' => 'Static', 'desc' => 'static text', 'raw_name' => 'static' }
    assert_equal should_be, Extension.load_yaml_data('static')
  end
  
  def test_should_raise_error_on_loading_nonexistent_yaml_data
    assert_raise(ExtensionYAMLDoesntExistException) { Extension.load_yaml_data('blabalbalabla') }
  end
  
  def test_should_generate_yaml_filename_for_extension
    assert_equal Extension.path + '/test/extension.yml', Extension.generate_yaml_filename('test')
  end
  
  def test_should_error_on_nonexistent_install
    assert_raise (ExtensionFileMissingException) { Extension.install('non_existent') }
  end
  
  def test_should_install_successfully_on_not_installed_extension
    install_not_installed
    uninstall_not_installed
  end
  
  def test_should_error_on_already_installed_during_install
    install_not_installed
    assert_raise (ExtensionAlreadyInstalledException) { Extension.install('not_installed') }
    uninstall_not_installed
  end
  
  def test_should_load_correct_extension_class_on_installed_extension
    install_not_installed
    ext = Extension.find_by_name('not_installed')
    assert_not_nil ext
    assert_equal 'NotInstalledExt', ext.extklass.class.to_s
    
    uninstall_not_installed
  end
  
  def test_should_error_during_uninstall_of_not_installed_extension
    assert_raise (ExtensionNotInstalledException) { Extension.uninstall('what-are-you-talking-about') }
  end
  
  def test_should_uninstall_installed_extension_and_no_longer_find_it_in_database
    install_not_installed
    uninstall_not_installed
    assert_equal false, Extension.exists?('not_installed')
  end
  
  def load_static_ext
    Extension.install('static') unless Extension.exists?('static')
    ext = Extension.find_by_name('static')
    assert_not_nil ext.extklass
    assert_equal 'StaticExt', ext.extklass.class.to_s
    return ext
  end

  def test_should_error_on_nonexistent_path_to_extensions
    bad_path = File.dirname(__FILE__) + '/../this/better/not/exist'
    assert_equal false, Extension.set_path(bad_path)
  end
  
  def test_should_succeed_on_setting_existent_path_to_extensions
    assert_equal GOOD_EXTENSION_PATH, Extension.path
  end

  def test_should_error_on_loading_extension_where_extension_file_is_missing
    assert_raise (ExtensionFileMissingException) { Extension.find(extensions(:nonexistent).id) }
  end
  
  def test_should_succeed_in_loading_with_wrong_casing_supplied
    Extension.install('static') unless Extension.exists?('static')
    ext = Extension.find_by_name('static')
    assert_not_nil ext
    ext.name = 'STATIC'
    assert ext.load
  end
  
  def test_should_error_on_loading_with_finding_file_but_no_class
    load_static_ext
    
    assert_raise (ExtensionNoClassException) { Extension.find(extensions(:bad_class_name).id) }
  end
  
  def test_should_succeed_in_calling_good_extension_class_methods
    ext = load_static_ext
    assert_equal 'Pass', ext.test_pass
    assert_equal 'Pass', ext.ext_test_pass
    assert_equal 'Pass'.reverse, ext.ext_test_args('Pass')
    assert_equal 'Pass', ext.run_method('test_pass')
    assert_equal 'Pass'.reverse, ext.run_method('test_args', 'Pass')
  end
  
  def test_should_forward_extension_as_param_with_forward_method
    ext = load_static_ext
    assert_equal 'static', ext.forward('test_forward')
    assert_equal 'themes_work_too', Theme::extension_contents
  end
end
