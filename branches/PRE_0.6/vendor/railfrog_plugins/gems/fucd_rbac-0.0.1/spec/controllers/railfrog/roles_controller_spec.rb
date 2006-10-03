require File.dirname(__FILE__) + '/../../spec_helper'

module Railfrog
  context "GET to /roles" do
    include SpecHelpers
    controller_name 'railfrog/roles'
  
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
  
  context "GET to /roles/new" do
    controller_name 'railfrog/roles'
    
    setup do
      get :new
    end
    
    specify "should create a new role" do
      response.should_be_success
    end
  end
  
  context "GET to /roles/edit/1" do
    include SpecHelpers
    controller_name 'railfrog/roles'
    
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
  
  context "GET to /roles/show/1" do
    include SpecHelpers
    controller_name 'railfrog/roles'
    
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
  
  context "POST to /roles with valid attributes" do
    include SpecHelpers
    controller_name 'railfrog/roles'
    
    setup do
      Role.any_instance.stubs(:save).returns(role_count = 1)
      Role.stubs(:count).returns(role_count || 0)
      post :create, :role => required_role_attributes
    end
    
    specify "should create new role 'editor'" do
      Role.count.should_be 1
    end
    
    specify "should redirect to show new role" do
      response.should_be_redirect
      response.redirect_url.should_equal railfrog_role_url(assigns(:role))
    end
  end
  
  context "PUT to /roles/1" do
    include SpecHelpers
    controller_name 'railfrog/roles'
    
    setup do
      @role = Role.new required_role_attributes
      @role.stubs(:save).returns(true)
      Role.stubs(:find).with { |id| id.to_i == 1 }.returns(@role)
      put :update, :id => 1, :role => { :name => 'supervisor'} 
    end
    
    specify "should update role 'editor'" do
      Role.find(1).name.should_equal 'supervisor'
    end
    
    specify "should redirect to /roles/show/<id>" do
      response.should_be_redirect
      response.redirect_url.should_equal railfrog_role_url(assigns(:role))
    end
  end
  
  context "DELETE to /roles/<id>" do
    include SpecHelpers
    controller_name 'railfrog/roles'
    
    setup do
      @role = Role.new required_role_attributes
      @role.stubs(:destroy).returns(role_count = 0)
      Role.stubs(:count).returns(role_count || 1)
      Role.stubs(:find).with('1').returns(@role)
      delete :destroy, :id => 1
    end
    
    specify "should delete role 'editor'" do
      Role.count.should_be 0
    end
    
    specify "should redirect to /roles" do
      response.should_be_redirect
      response.redirect_url.should_equal railfrog_roles_url
    end
  end
end
