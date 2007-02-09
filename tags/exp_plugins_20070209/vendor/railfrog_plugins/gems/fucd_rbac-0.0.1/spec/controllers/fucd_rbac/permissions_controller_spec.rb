require File.dirname(__FILE__) + '/../../spec_helper'

module FucdRbac
  PermissionsController.send(:include, FakeAuthorization)
  
  context "GET to fucd_rbac/permissions" do
    controller_name 'fucd_rbac/permissions'
  
    setup do
      @permission = mock('permission')
    end
    
    specify "should find all associated permissions to role with id=1" do
      Permission.should_receive(:find_all_by_role_id).with('1').and_return([@permission])
      
      get :index, :role_id => 1
      
      assigns(:permissions).should == [@permission]
    end
    
    specify "should ... when given id to an inexisting role" do
      get :index, :role_id => 2
    end
  end
  
  context "GET to fucd_rbac/permissions/new" do
    controller_name 'fucd_rbac/permissions'
    
    setup do
      get :new, :role_id => 1
    end
    
    specify "should be successful" do
      response.should_be_success #TODO
    end
  end
  
  context "GET to fucd_rbac/permissions/edit/1" do
    controller_name 'fucd_rbac/permissions'
    
    setup do
      @permission = mock('permission')
    end
    
    specify "should get permission with id=1 " do
      @permission = mock('permission')
      Permission.should_receive(:find).with('1').and_return(@permission)
      
      get :edit, :id => 1, :role_id => 1
      
      assigns(:permission).should == @permission
    end
  end
  
  context "POST to fucd_rbac/permissions" do
    controller_name 'fucd_rbac/permissions'
    
    setup do
      @permission = mock('permission')
      @permission.stub!(:to_s).and_return(1)
      @role = mock('role')
      @role_permission = mock('role<->permission') #TODO
      Role.stub!(:find).and_return(@role)
      @role.stub!(:permissions).and_return(@role_permission)
      @role_permission.stub!(:build).and_return(@permission)
    end
    
    specify "should try to create new permission" do
      @permission.should_receive(:save)
      @role_permission.should_receive(:build).with("action" => ".*").and_return(@permission)
      
      post :create, :permission => { "action" => ".*" }, :role_id => 1
    end
    
    specify "should redirect to action 'index' after successful save" do
      @permission.stub!(:save).and_return(true)
      controller.should_redirect_to :action => 'index', :role_id => 1
      
      post :create, :role_id => 1
    end
    
    specify "should render action 'new' after failed save" do
      @permission.stub!(:save).and_return(false)
      
      controller.should_render :action => 'new'
      
      post :create, :role_id => 1
      
      assigns(:permission).should == @permission
    end
  end
  
  context "PUT to fucd_rbac/permissions/1" do
    controller_name 'fucd_rbac/permissions'
    
    setup do
      @permission = mock('permission')
      @permission.stub!(:to_s).and_return(1)
      Permission.stub!(:find).and_return(@permission)
    end
    
    specify "should try to update permission with id=1" do
      @permission.should_receive(:update_attributes).with("action" => ".*")
      Permission.should_receive(:find).with('1').and_return(@permission)
      
      put :update, :id => 1, :permission => { "action" => ".*" }, :role_id => 1
    end
    
    specify "should redirect to action 'index' after successful update" do
      @permission.should_receive(:update_attributes).and_return(true)
      
      controller.should_redirect_to :action => 'index', :role_id => 1
      
      put :update, :id => 1, :role_id => 1
    end
    
    specify "should render action 'edit' after failed update" do
      @permission.should_receive(:update_attributes).and_return(false)
      
      controller.should_render :action => 'edit'
      
      put :update, :id => 1, :role_id => 1
      
      assigns(:permission).should == @permission
    end
  end
  
  context "DELETE to fucd_rbac/permissions/1" do
    controller_name 'fucd_rbac/permissions'
    
    setup do
      @permission = mock('permission')
      @permission.stub!(:destroy)
      Permission.stub!(:find).and_return(@permission)
    end
    
    specify "should delete permission with id=1" do
      @permission.should_receive(:destroy)
      Permission.should_receive(:find).with('1').and_return(@permission)
      
      delete :destroy, :id => 1, :role_id => 1
    end
    
    specify "should redirect to action 'index'" do
      controller.should_redirect_to :action => 'index', :role_id => 1
      
      delete :destroy, :id => 1, :role_id => 1
    end
  end
end
