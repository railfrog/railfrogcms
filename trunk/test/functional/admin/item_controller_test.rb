require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/item_controller'

# Re-raise errors caught by the controller.
class Admin::ItemController; def rescue_action(e) raise e end; end

class Admin::ItemControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::ItemController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    set_good_extension_path
    Extension.install('static') unless Extension.exists?('static')
    Extension.install('not_installed') unless Extension.exists?('not_installed')
    Extension.install('bold') unless Extension.exists?('bold')
    @bold_ext_id = Extension.find_by_name('bold').id
    @good_ext_id = Extension.find_by_name('static').id
    @bad_ext_id = Extension.find_by_name('not_installed').id
  end
  
  def create_item(item_name, extension_id = @bad_ext_id)
    post :create, { :newitem => { :extension_id => extension_id, :name => item_name } }
    item = Item.find_by_name(item_name)
    assert_not_nil item
    item
  end
  
  def test_should_get_language_list_on_edit
    item = create_item('edit-me')
    Locale.set('eng')
    item['hey'] = 'hi'
    
    get :edit_language, { :id => item.id }
    assert_rendered_file 'admin/item/edit_language'
    assert assigns.has_key?('languages')
    assert assigns.has_key?('edititem')
    assert_equal 1, assigns['languages'].length
    
    Locale.set('spa')
    item['hey'] = 'hola'
    
    get :edit_language, { :id => item.id }
    assert_rendered_file 'admin/item/edit_language'
    assert assigns.has_key?('languages')
    assert assigns.has_key?('edititem')
    assert_equal 2, assigns['languages'].length
  end

  def test_should_create_item_list_on_index
    get :index
    assert_not_nil assigns['items']
    assert_rendered_file 'admin/item/index'
  end
  
  def test_should_show_new_item_form_and_assign_correct_variables
    get :new
    assert_not_nil assigns['newitem']
    assert_not_nil assigns['extensions']
    assert_rendered_file 'admin/item/new'
  end
  
  def test_should_show_errors_on_bad_new_item
    post :create, { :newitem => { :extension_id => @bad_ext_id, :name => '' } }
    assert flash.has_key?(:error)
    assert_rendered_file 'admin/item/new'
    
    post :create, { :newitem => { :extension_id => @bad_ext_id, :name => 'exists' } }
    assert_rendered_file 'admin/item/create'
    
    post :create, { :newitem => { :extension_id => @bad_ext_id, :name => 'exists' } }
    assert flash.has_key?(:error)
    assert_rendered_file 'admin/item/new'
  end
  
  def test_should_show_extension_created_on_new_item_without_install_on_extension
    item = create_item('noform')
    assert_rendered_file 'admin/item/create'
    assert_equal 0, item.temp
  end
  
  def test_should_route_running_extension_methods_to_correct_action
    options = { :extension_id => '1', :id => '2', :extension_method => 'test_run', :controller => 'admin/item', :action => 'extension' }
    assert_routing('admin/item/extension/1/test_run/2', options)
    
    options = { :extension_id => '1', :id => '2', :extension_method => 'test_run', :controller => 'admin/item', :action => 'extension_ajax' }
    assert_routing('admin/item/extension/ajax/1/test_run/2', options)
  end
  
  def test_should_forward_extension_created_to_extension_new_item_form
    item = create_item('forward-me', @good_ext_id)
    assert_equal 1, item.temp
    assert_rendered_file 'admin/item/extension'
  end
  
  def test_should_delete_item_on_destroy
    item = create_item('delete-me')
    assert_rendered_file 'admin/item/create'
    
    get :destroy_with_ajax, { :id => item.id }
    assert_nil Item.find_by_name('delete-me')
    assert_rendered_file 'admin/item/index'
  end
  
  def test_should_redirect_back_to_index_on_destroy_without_ajax
    item = create_item('delete-me')
    assert_rendered_file 'admin/item/create'
    
    get :destroy, { :id => item.id }
    assert_nil Item.find_by_name('delete-me')
    assert_rendered_file 'admin/item/index'
  end
  
  def test_should_show_edit_form
    item = create_item('delete-me')
    assert_rendered_file 'admin/item/create'
    
    get :edit, { :id => item.id }
    assert_not_nil assigns['edititem']
    get :edit_with_ajax, { :id => item.id }
    assert_not_nil assigns['edititem']
  end
  
  def test_should_rename_item
    item = create_item('edit-my-name')
    assert_rendered_file 'admin/item/create'
    
    post :do_rename, { :id => item.id, :edititem => { :name => 'edit-me-now' } }
    assert_rendered_file 'admin/item/edit_language'
    item.reload
    assert_equal 'edit-me-now', item.name
    
    post :do_rename_with_ajax, { :id => item.id, :edititem => { :name => 'edit-me-now-again' } }
    assert_rendered_file 'admin/item/edit_language'
    item.reload
    assert_equal 'edit-me-now-again', item.name
  end
  
  def test_should_quick_delete_multiple_items
    d1 = create_item('delete-1')
    d2 = create_item('delete-2')
    d3 = create_item('nodelete-3')
    
    post :quickedit, { :quick_edit => 'delete', ('item_' + d1.id.to_s) => 1, ('item_' + d2.id.to_s) => 1 }
    assert_rendered_file 'admin/item/index'
    assert_raise(ActiveRecord::RecordNotFound) { d1.reload }
    assert_raise(ActiveRecord::RecordNotFound) { d2.reload }
    assert_nothing_raised { d3.reload }
  end
  
  def test_should_quick_delete_multiple_items_with_ajax
    d1 = create_item('delete-1')
    d2 = create_item('delete-2')
    d3 = create_item('nodelete-3')
    
    post :quickedit_ajax, { :quick_edit => 'delete', ('item_' + d1.id.to_s) => 1, ('item_' + d2.id.to_s) => 1 }
    assert_rendered_file 'admin/item/index'
    assert_raise(ActiveRecord::RecordNotFound) { d1.reload }
    assert_raise(ActiveRecord::RecordNotFound) { d2.reload }
    assert_nothing_raised { d3.reload }
  end
  
  def test_should_quick_add_content_extensions
    d1 = create_item('get-ext-1')
    d2 = create_item('get-ext-2')

    assert_equal false, d1.has_extension?(:bold)
    assert_equal false, d2.has_extension?(:bold)
    post :do_quickedit_content, { ('item_' + d1.id.to_s) => 1, ('item_' + d2.id.to_s) => 1, :extensions_chosen => { ('content_' + @bold_ext_id.to_s) => '1' } }
    assert_rendered_file 'admin/item/index'
    assert d1.has_extension?(:bold)
    assert d2.has_extension?(:bold)
  end
  
  def test_should_quick_add_content_extensions_with_ajax
    d1 = create_item('get-ext-1-ajax')
    d2 = create_item('get-ext-2-ajax')

    assert_equal false, d1.has_extension?(:bold)
    assert_equal false, d2.has_extension?(:bold)
    post :do_quickedit_content_ajax, { ('item_' + d1.id.to_s) => 1, ('item_' + d2.id.to_s) => 1, :extensions_chosen => { ('content_' + @bold_ext_id.to_s) => '1' } }
    assert_rendered_file 'admin/item/index'
    assert d1.has_extension?(:bold)
    assert d2.has_extension?(:bold)
  end
end
