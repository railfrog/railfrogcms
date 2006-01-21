require File.dirname(__FILE__) + '/../test_helper'
require 'item_controller'

# Re-raise errors caught by the controller.
class ItemController; def rescue_action(e) raise e end; end

class ItemControllerTest < Test::Unit::TestCase
  fixtures :items, :characteristics, :extensions

  def setup
    @controller = ItemController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    set_good_extension_path
    set_fake_renderer
  end
  
  def test_should_return_index_item_content_on_no_item_passed
    get :view_item
    assert_response :success
    
    item_one = Item.find(items(:index).id, :include => :extension)
    item_one.extklass.view(item_one)
    assert_equal Theme::extension_contents, @response.body
  end

  def test_should_return_content_of_item_passed_to_view_item
    get :view_item, { :item => 'item-one' }
    assert_response :success
    
    item_one = Item.find(items(:item1).id, :include => :extension)
    item_one.extklass.view(item_one)
    assert_equal Theme::extension_contents, @response.body
  end
  
  def test_should_successfully_run_items_extension_method
    get :run_item, { :item => 'item-one', :method => 'test_run' }
    assert_response :success
    
    item_one = Item.find(items(:item1).id, :include => :extension)
    assert_equal item_one.extklass.test_run, @response.body
  end
  
  def test_should_return_404_item_content_on_missing_item
    get :view_item, { :item => 'some_unknown_whosamawhatsit' }
    assert_response 404
    
    item_404 = Item.find_by_name(options(:item404).value, :include => :extension)
    item_404.ext_view(item_404)
    assert_equal Theme::extension_contents, @response.body
  end
  
  def test_should_route_item_name_to_correct_address
    options = { :item => 'item-one', :controller => 'item', :action => 'view_item' }
    assert_routing('item-one', options)
  end
  
  def test_should_route_item_name_and_extension_method_to_correct_address
    options = { :item => 'item-one', :method => 'test_run', :controller => 'item', :action => 'run_item' }
    assert_routing('item-one/test_run', options)
  end
end
