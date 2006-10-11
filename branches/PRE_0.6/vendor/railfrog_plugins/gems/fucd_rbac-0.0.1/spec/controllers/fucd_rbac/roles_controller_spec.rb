require File.dirname(__FILE__) + '/../../spec_helper'

module FucdRbac
  RolesController.send(:include, FakeAuthorization)
  
  context "GET to fucd_rbac/roles" do
    include SpecHelpers
    controller_name 'fucd_rbac/roles'
  
    setup do
      @role = Role.new required_role_attributes
      Role.stubs(:find).with(:all).returns([@role])
      get :index
    end
    
    specify "should find all roles" do
      response.should_be_success
      assigns(:roles).should_equal [@role]
    end
  end
  
  context "GET to fucd_rbac/roles/new" do
    controller_name 'fucd_rbac/roles'
    
    setup do
      get :new
    end
    
    specify "should be successful" do
      response.should_be_success
    end
  end
  
  context "GET to fucd_rbac/roles/edit/1" do
    include SpecHelpers
    controller_name 'fucd_rbac/roles'
    
    setup do
      @role = Role.new required_role_attributes
      Role.stubs(:find).with('1').returns(@role)
      get :edit, :id => 1
    end
    
    specify "should edit the role 'editor'" do
      response.should_be_success
      assigns(:role).should_equal @role
    end
  end
  
  context "GET to fucd_rbac/roles/show/1" do
    include SpecHelpers
    controller_name 'fucd_rbac/roles'
    
    setup do
      @role = Role.new required_role_attributes
      @role.stubs(:id).returns(1)
      Role.stubs(:find).with('1').returns(@role)
      get :show, :id => 1
    end
    
    specify "should show the role 'editor'" do
      response.should_be_success
      assigns(:role).should_equal @role
    end
  end
  
  context "POST to fucd_rbac/roles with valid attributes" do
    include SpecHelpers
    controller_name 'fucd_rbac/roles'
    
    setup do
      post :create, :role => required_role_attributes
    end
    
    specify "should create new role 'editor'" do
      Role.count.should_be 1
    end
    
    specify "should redirect to show new role" do
      response.should_be_redirect
      response.redirect_url.should_equal fucd_rbac_role_url(assigns(:role))
    end
  end
  
  context "POST to fucd_rbac/roles with invalid attributes" do
    include SpecHelpers
    controller_name 'fucd_rbac/roles'
    
    setup do
      post :create, :role => required_role_attributes.except(:name)
    end
    
    specify "should not create a new role" do
      Role.count.should_be 0
    end
    
    specify "should raise model errors" do
      assigns(:role).errors.should_not_be nil
    end
    
    specify "should render new" do
      response.should_render :new
    end
  end
  
  context "PUT to fucd_rbac/roles/<id> with valid attributes" do
    include SpecHelpers
    controller_name 'fucd_rbac/roles'
    
    setup do
      @role = Role.create required_role_attributes
      put :update, :id => @role.id, :role => { :name => 'supervisor'} 
    end
    
    specify "should update role 'editor'" do
      Role.find(@role.id).name.should_equal 'supervisor'
    end
    
    specify "should redirect to show role 'editor'" do
      response.should_be_redirect
      response.redirect_url.should_equal fucd_rbac_role_url(assigns(:role))
    end
  end
  
  context "PUT to fucd_rbac/roles/<id> with invalid attributes" do
    include SpecHelpers
    controller_name 'fucd_rbac/roles'
    
    setup do
      @role = Role.create required_role_attributes
      put :update, :id => @role.id, :role => { :name => '' }
    end
    
    specify "should not update role 'editor'" do
      Role.find(@role.id).name.should_equal @role.name
    end
    
    specify "should raise model errors" do
      assigns(:role).errors.should_not_be nil
    end
    
    specify "should render edit" do
      response.should_render :edit
    end
  end
  
  context "DELETE to fucd_rbac/roles/<id>" do
    include SpecHelpers
    controller_name 'fucd_rbac/roles'
    
    setup do
      @role = Role.create required_role_attributes
      delete :destroy, :id => @role.id
    end
    
    specify "should delete role 'editor'" do
      Role.count.should_be 0
    end
    
    specify "should redirect to index" do
      response.should_be_redirect
      response.redirect_url.should_equal fucd_rbac_roles_url
    end
  end
end
