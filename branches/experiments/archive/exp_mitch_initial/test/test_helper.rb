ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  GOOD_EXTENSION_PATH = File.dirname(__FILE__) + '/extensions'
  GOOD_THEME_PATH = File.dirname(__FILE__) + '/themes'
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...
  fixtures :options, :globalize_countries, :globalize_languages, :users, :permissions, :roles, :role_permissions
  
  def set_good_extension_path
    assert Extension.set_path(GOOD_EXTENSION_PATH)
  end
  
  def set_good_theme_path
    assert_equal true, Theme::set_path(GOOD_THEME_PATH)
    assert_equal GOOD_THEME_PATH, Theme::get_path
  end
  
  def set_good_session_hash
    @session = {}
    assert User.set_session(@session)
  end
  
  def set_fake_renderer
    assert_equal true, Theme::set_renderer(self.method(:fake_renderer))
  end
  
  def fake_renderer(contents, options = {})
    return contents
  end
  
  def login_mitch
    assert User.login(users(:mitch).login, 'woohoo')
    assert User.logged_in?
  end
  
  def setup_permissions
    assert Permission.set('access_admin', 'Access Administrative Panel')
    assert Permission.set('basic_create', 'Basic Create')
    assert Permission.set('basic_delete', 'Basic Delete')
  end
  
  def setup_roles
    assert Role.set('admin', 'Administrator')
    assert Role.set('parent', 'Parent')
    assert Role.set('child', 'Child')
    assert Role.set_parent('child', 'parent')
    assert Role.set_default('child')
  end
end

class Test::Unit::TestCase
  def assert_rendered_file(expected_file)
    assert_equal expected_file, Theme::rendered_file
  end
end