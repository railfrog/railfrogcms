require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/containers_controller'

# Re-raise errors caught by the controller.
class Admin::ContainersController; def rescue_action(e) raise e end; end

class Admin::ContainersControllerTest < Test::Unit::TestCase
  fixtures :containers

  def setup
    @controller = Admin::ContainersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:containers)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:container)
    assert assigns(:container).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:container)
  end

  def test_create
    num_containers = Container.count

    post :create, :container => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_containers + 1, Container.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:container)
    assert assigns(:container).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Container.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Container.find(1)
    }
  end
end
