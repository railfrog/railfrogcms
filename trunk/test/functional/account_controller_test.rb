require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase
  def setup
    Locale.set('eng')
    setup_roles
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_show_signup_page_on_request
    get :new
    assert_not_nil assigns['newuser']
    assert_kind_of User, assigns['newuser']
    assert_rendered_file 'account/new'
  end
  
  def test_should_redirect_on_bad_params_or_method_with_create
    get :create
    assert_response 302
    assert_redirected_to :action => 'new'
  end
  
  def test_should_redirect_on_bad_params_or_method_with_create_with_ajax  
    get :create_with_ajax
    assert_response 302
    assert_redirected_to :action => 'new'
  end
  
  def test_should_render_error_page_on_signup_with_ajax_error
    post :create_with_ajax, { :newuser => { :login => 'test_invalid', :password => 'asdf', :password_confirmation => 'doesntmatch' } }
    assert_rendered_file 'account/new'
    
    newuser = User.find_by_login('test_invalid')
    assert_nil newuser
  end
  
  def test_should_render_error_page_on_signup_error
    post :create, { :newuser => { :login => 'test_invalid', :password => 'asdf', :password_confirmation => 'doesntmatch' } }
    assert_rendered_file 'account/new'
    
    newuser = User.find_by_login('test_invalid')
    assert_nil newuser
  end
  
  def test_should_render_ajax_success_page_on_create_with_ajax
    post :create_with_ajax, { :newuser => { :login => 'test', :password => 'test', :password_confirmation => 'test' } }
    assert_rendered_file 'account/create'
    
    newuser = User.find_by_login('test')
    assert_not_nil newuser
  end
  
  def test_should_render_success_page_on_create
    post :create, { :newuser => { :login => 'test2', :password => 'test', :password_confirmation => 'test' } }
    assert_rendered_file 'account/create'
    
    newuser = User.find_by_login('test2')
    assert_not_nil newuser
  end
  
  def test_should_render_login_template
    get :login
    assert_rendered_file 'account/login'
    assert_not_nil assigns['inuser']
  end
  
  def test_should_render_login_template_on_errors
    post :do_login, { :inuser => { :login => 'i-dont-exist' } }
    assert_rendered_file 'account/login'
    
    post :do_login, { :inuser => { :login => users(:mitch).login, :password => 'bad' } }
    assert_rendered_file 'account/login'
  end
  
  def test_should_render_logged_in_template_on_success
    user = User.authenticate
    assert_nil user
    
    post :do_login, { :inuser => { :login => users(:mitch).login, :password => 'woohoo' }}
    assert_rendered_file 'account/logged_in'
    
    user = User.authenticate
    assert_not_nil user
    assert_equal 'User', user.class.to_s
    assert_equal users(:mitch).login, user.login
  end
  
  def test_should_log_out_user
    post :do_login, { :inuser => { :login => users(:mitch).login, :password => 'woohoo' }}
    assert_rendered_file 'account/logged_in'
    
    user = User.authenticate
    assert_not_nil user
    assert_equal 'User', user.class.to_s
    assert_equal users(:mitch).login, user.login
    
    get :logout
    assert_rendered_file 'account/logout'
    
    user = User.authenticate
    assert_nil user
  end
end
