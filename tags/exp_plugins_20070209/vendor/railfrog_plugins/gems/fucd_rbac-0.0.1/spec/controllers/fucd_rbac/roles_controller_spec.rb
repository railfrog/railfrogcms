require File.dirname(__FILE__) + '/../../spec_helper'

module FucdRbac
  RolesController.send(:include, FakeAuthorization)
  
  context "GET to fucd_rbac/roles" do
    controller_name 'fucd_rbac/roles'
    
    specify "should find all roles" do
      @role = mock('role')
      Role.should_receive(:find).with(:all).and_return([@role])
      
      get :index
      
      assigns(:roles).should == [@role]
    end
  end
  
  context "GET to fucd_rbac/roles/new" do
    controller_name 'fucd_rbac/roles'
    
    setup do
      get :new
    end
    
    specify "should be successful" do
      response.should_be_success #TODO
    end
  end
  
  context "GET to fucd_rbac/roles/edit/1" do
    controller_name 'fucd_rbac/roles'
    
    specify "should get role with id=1" do
      @role = mock('role')
      Role.should_receive(:find).with('1').and_return(@role)
      
      get :edit, :id => 1
      
      assigns(:role).should == @role
    end
  end
  
  context "GET to fucd_rbac/roles/show/1" do
    controller_name 'fucd_rbac/roles'
    
    specify "should get role with id=1" do
      @role = mock('role')
      Role.should_receive(:find).with('1').and_return(@role)
      
      get :show, :id => 1
      
      assigns(:role).should == @role
    end
  end
  
  context "POST to fucd_rbac/roles" do
    controller_name 'fucd_rbac/roles'
    
    setup do
      @role = mock('role')
      @role.stub!(:to_s).and_return(1)
      Role.stub!(:new).and_return(@role)
    end
    
    specify "should try to create new role" do
      @role.should_receive(:save)
      Role.should_receive(:new).with("name" => "Editor").and_return(@role)
      
      post :create, :role => { "name" => "Editor" }
    end

    specify "should redirect to show new role after successful save" do
      @role.stub!(:save).and_return(true)
      controller.should_redirect_to :action => 'show', :id => 1
            
      post :create
    end
    
    specify "should render action 'new' after failed save" do
      @role.stub!(:save).and_return(false)
      
      controller.should_render :action => 'new'
      
      post :create
      
      assigns(:role).should == @role
    end
  end
  
  
  context "PUT to fucd_rbac/roles/1" do
    controller_name 'fucd_rbac/roles'
    
    setup do
      @role = mock('role')
      @role.stub!(:to_s).and_return(1)
      Role.stub!(:find).and_return(@role)
    end
    
    specify "should try to update role with id=1" do
      @role.should_receive(:update_attributes).with("name" => "Editor")
      Role.should_receive(:find).with('1').and_return(@role)
      
      put :update, :id => 1, :role => { "name" => "Editor" }
    end
    
    specify "should redirect to show role with id=1 after successful update" do
      @role.should_receive(:update_attributes).and_return(true)
      controller.should_redirect_to :action => 'show', :id => 1
      
      put :update, :id => 1
    end
    
    specify "should render action 'edit' after failed update" do
      @role.should_receive(:update_attributes).and_return(false)
      
      controller.should_render :action => 'edit'
      
      put :update, :id => 1
      
#      assigns(:role).should == @role
    end
  end
  
  context "DELETE to fucd_rbac/roles/1" do
    controller_name 'fucd_rbac/roles'
    
    setup do
      @role = mock('role')
      @role.stub!(:destroy)
      Role.stub!(:find).and_return(@role)
    end
    
    specify "should delete role with id=1" do
      @role.should_receive(:destroy)
      Role.should_receive(:find).with('1').and_return(@role)
      
      delete :destroy, :id => 1
    end
    
    specify "should redirect to index" do
      controller.should_redirect_to :action => 'index'
      
      delete :destroy, :id => 1
    end
  end
end
