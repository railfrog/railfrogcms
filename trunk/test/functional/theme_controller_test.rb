require File.dirname(__FILE__) + '/../test_helper'
require 'theme_controller'

# Re-raise errors caught by the controller.
class ThemeController; def rescue_action(e) raise e end; end

class ThemeControllerTest < Test::Unit::TestCase
  def setup
    @controller = ThemeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    set_good_theme_path
    set_fake_renderer
  end
  
  def test_should_return_404_on_attempting_to_change_directories
    get :resource, { :resource => '..', :filename => 'install.rhtml' }
    assert_equal '404', @response.body
    assert_response :missing
    
    get :resource, { :resource => 'test', :filename => '../install.rhtml' }
    assert_equal '404', @response.body
    assert_response :missing
  end

  def test_should_get_resource_data
    get :resource, { :resource => 'test', :filename => 'hi.txt' }
    assert_equal 'Hi!',@response.body
    assert_equal 'text/plain', @response.headers['Content-Type']
  end
  
  def test_should_get_resource_data_from_specific_theme
    get :resource, { :resource => 'test', :filename => 'hi.txt', :theme => 'dummy' }
    assert_equal 'Yo!',@response.body
    assert_equal 'text/plain', @response.headers['Content-Type']
  end
  
  def test_should_process_erb_on_resource_data_on_request
    get :resource, { :resource => 'test', :filename => 'erb.txt', :build => 'true', :test => 'Yay' }
    assert_equal 'Yay',@response.body
    assert_equal 'text/plain', @response.headers['Content-Type']
  end
  
  def test_should_route_url_to_resource
    options = { :resource => 'test', :filename => 'hi.txt', :controller => 'theme', :action => 'resource' }
    assert_routing('theme/test/hi.txt', options)
  end
  
  def test_should_route_url_with_theme_to_resource
    options = { :resource => 'test', :filename => 'hi.txt', :theme => 'dummy', :controller => 'theme', :action => 'resource' }
    assert_routing('theme/dummy/test/hi.txt', options)
  end
end
