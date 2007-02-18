require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  def setup
    setup_permissions
    setup_roles
  end

  def test_should_create_user
    newuser = User.new
    newuser.login = 'Test'
    newuser.password = 'Yay'
    assert newuser.save!
    assert newuser.destroy
  end
  
  def test_should_raise_error_when_removing_existent_role
    mitch = User.find(users(:mitch).id)
    assert_equal 0, mitch.roles.length
    assert_raise(UserDoesntHaveRoleException) { mitch.remove_role(:admin) }
  end
  
  def test_should_raise_error_when_adding_existent_role
    mitch = User.find(users(:mitch).id)
    assert_equal 0, mitch.roles.length
    assert mitch.add_role(:admin)
    assert_equal 1, mitch.roles.length
    assert_raise(UserAlreadyHasRoleException) { mitch.add_role(:admin) }
    assert mitch.remove_role(:admin)  
    assert_equal 0, mitch.roles.length
  end
  
  def test_should_add_and_remove_role_fromto_user
    mitch = User.find(users(:mitch).id)
    assert_equal 0, mitch.roles.length
    assert mitch.add_role(:admin)
    assert_equal 1, mitch.roles.length
    assert mitch.remove_role(:admin)  
    assert_equal 0, mitch.roles.length
  end
  
  def test_should_remove_habtm_association_on_removal
    newuser = User.new
    newuser.login = 'yayyyyy'
    newuser.password = 'Yay'
    assert newuser.save!
    assert newuser.add_role(:parent)
    assert_equal 1, newuser.roles.size
    assert newuser.destroy
    assert_equal 0, RolesUser.find_all_by_user_id(newuser.id).length
  end
  
  def test_should_check_permissions_with_roles
    mitch = User.find(users(:mitch).id)
    assert mitch.add_role(:admin)
    assert RolePermission.set(:admin, :basic_create, 1)
    assert RolePermission.set(:admin, :basic_delete)
    assert mitch.has_permission?(:basic_create)
    assert_equal false, mitch.has_permission?(:basic_delete)
    assert mitch.remove_role(:admin)
  end
  
  def test_should_hash_password_when_setting_explicity
    newuser = User.new
    newuser.password = 'Test'
    
    assert_equal Auth::hash('Test'), newuser.password
    assert_equal 'Test', newuser.raw_password
  end
  
  def test_should_only_allow_unique_login
    newuser = User.new
    newuser.login = 'Test'
    newuser.password = 'Foo'
    assert_nothing_raised(ActiveRecord::RecordInvalid) { newuser.save! }
    
    nextuser = User.new
    nextuser.login = 'Test'
    nextuser.password = 'Whatever'
    assert_raise(ActiveRecord::RecordInvalid) { nextuser.save! }
  end
  
  def test_should_store_session_as_class_variable
    session = {}
    assert User.set_session(session)
  end
  
  def test_should_save_session_on_successful_login
    set_good_session_hash
    login_mitch
    assert User.logged_in?
  end
  
  def test_should_load_user_object_on_good_login
    set_good_session_hash
    login_mitch
    
    user = User.authenticate
    assert_not_nil user
    assert_equal 'User', user.class.to_s
    assert_equal users(:mitch).login, user.login
  end
  
  def test_should_clear_session_on_logout
    set_good_session_hash
    login_mitch
    
    assert User.logout
    assert @session[:auth].nil?
  end
  
  def test_should_error_on_bad_login
    set_good_session_hash
    assert_raise (UserDoesntExistException) { User.login('random', 'random') }
  end
  
  def test_should_error_on_bad_password
    set_good_session_hash
    assert_raise (InvalidPasswordException) { User.login(users(:mitch).login, 'badpass') }
  end
end
