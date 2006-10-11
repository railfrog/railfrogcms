require File.dirname(__FILE__) + '/../../spec_helper'

module FucdRbac
  PermissionsController.send(:include, FakeAuthorization)
  
  context "GET to fucd_rbac/permissions with :role_id=1 (=correct)" do
    include SpecHelpers
    controller_name 'fucd_rbac/permissions'
  
    setup do
      @permission = Permission.create required_permission_attributes
      get :index, :role_id => 1
    end
    
    specify "should find all associated permissions" do
      response.should_be_success
      assigns(:permissions).should_equal [@permission]
    end
  end
  
  context "GET to fucd_rbac/permissions with :role_id=2 (=wrong)" do
    include SpecHelpers
    controller_name 'fucd_rbac/permissions'
  
    setup do
      @permission = Permission.create required_permission_attributes
      get :index, :role_id => 2
    end
    
    specify "should not find any permissions" do
      response.should_be_success
      assigns(:permissions).should_equal []
    end
  end
  
  context "GET to fucd_rbac/permissions/new" do
    controller_name 'fucd_rbac/permissions'
    
    setup do
      get :new, :role_id => 1
    end
    
    specify "should be successful" do
      response.should_be_success
    end
  end
  
  context "GET to fucd_rbac/permissions/edit/<id> with :role_id=1 (=correct)" do
    include SpecHelpers
    controller_name 'fucd_rbac/permissions'
    
    setup do
      @permission = Permission.create required_permission_attributes
      get :edit, :id => @permission.id, :role_id => 1
    end
    
    specify "should edit the permission" do
      response.should_be_success
      assigns(:permission).should_equal @permission
    end
  end
  
  context "GET to fucd_rbac/permissions/edit/<id> with :role_id=2 (=wrong)" do
    include SpecHelpers
    controller_name 'fucd_rbac/permissions'
  
    setup do
      @permission = Permission.create required_permission_attributes
      get :edit, :id => @permission.id, :role_id => 2
    end
    
    specify "should not be successful" do
      #response.should_not_be_success
      assigns(:permission).should_be nil
    end
  end
  
  context "POST to fucd_rbac/permissions with valid attributes and :role_id=1 (=correct)" do
    include SpecHelpers
    controller_name 'fucd_rbac/permissions'
    
    setup do
      Role.stubs(:find).with('1').returns(Role.new)
      post :create, :permission => required_permission_attributes, :role_id => 1
    end
    
    specify "should create new permission" do
      Permission.count.should_be 1
    end
    
    specify "should redirect to index" do
      response.should_be_redirect
      response.redirect_url.should_equal fucd_rbac_permissions_url
    end
  end
  
  context "POST to fucd_rbac/permissions with invalid attributes and :role_id=1 (=correct)" do
    include SpecHelpers
    controller_name 'fucd_rbac/permissions'
    
    setup do
      Role.stubs(:find).with('1').returns(Role.new)
      post :create, :permission => required_permission_attributes.except(:action), :role_id => 1
    end
    
    specify "should not create a new permission" do
      Permission.count.should_be 0
    end
    
    specify "should raise model errors" do
      assigns(:permission).errors.should_not_be nil
    end
    
    specify "should render new" do
      response.should_render :new
    end
  end
  
  context "PUT to fucd_rbac/permissions/<id> with valid attributes and :role_id=1 (=correct)" do
    include SpecHelpers
    controller_name 'fucd_rbac/permissions'
    
    setup do
      @permission = Permission.create required_permission_attributes
      put :update, :id => @permission.id, :permission => { :action => 'foobar'}, :role_id => 1
    end
    
    specify "should update the permission" do
      Permission.find(@permission.id).action.should_equal 'foobar'
    end
    
    specify "should redirect to index" do
      response.should_be_redirect
      response.redirect_url.should_equal fucd_rbac_permissions_url
    end
  end
  
  context "PUT to fucd_rbac/permissions/<id> with invalid attributes and :role_id=1 (=correct)" do
    include SpecHelpers
    controller_name 'fucd_rbac/permissions'
    
    setup do
      @permission = Permission.create required_permission_attributes
      put :update, :id => @permission.id, :permission => { :action => nil }, :role_id => 1
    end
    
    specify "should not update the permission" do
      Permission.find(@permission.id).action.should_equal @permission.action
    end
    
    specify "should raise model errors" do
      assigns(:permission).errors.should_not_be nil
    end
    
    specify "should render edit" do
      response.should_render :edit
    end
  end
  
  context "PUT to fucd_rbac/permissions/<id> with valid attributes and :role_id=2 (=wrong)" do
    include SpecHelpers
    controller_name 'fucd_rbac/permissions'
    
    setup do
      @permission = Permission.create required_permission_attributes
      #FIXME: put :update, :id => @permission.id, :permission => { :action => 'foobar'}, :role_id => 2
    end
    
    specify "should not update the permission" do
      Permission.find(@permission.id).action.should_equal @permission.action
    end
    
    specify "should..." do
    end
  end
  
  context "DELETE to fucd_rbac/permissions/<id> with :role_id=1 (=correct)" do
    include SpecHelpers
    controller_name 'fucd_rbac/permissions'
    
    setup do
      @permission = Permission.create required_permission_attributes
      delete :destroy, :id => @permission.id, :role_id => 1
    end
    
    specify "should delete the permission" do
      Permission.count.should_be 0
    end
    
    specify "should redirect to index" do
      response.should_be_redirect
      response.redirect_url.should_equal fucd_rbac_permissions_url
    end
  end
  
  context "DELETE to fucd_rbac/permissions/<id> with :role_id=2 (=wrong)" do
    include SpecHelpers
    controller_name 'fucd_rbac/permissions'
    
    setup do
      @permission = Permission.create required_permission_attributes
      #FIXME: delete :destroy, :id => @permission.id, :role_id => 2
    end
    
    specify "should not delete the permission" do
      Permission.count.should_be 1
    end
    
    specify "should..." do
    end
  end
end
