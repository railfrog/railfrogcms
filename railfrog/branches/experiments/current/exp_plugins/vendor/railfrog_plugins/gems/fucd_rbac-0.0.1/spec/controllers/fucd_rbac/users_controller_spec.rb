require File.dirname(__FILE__) + '/../../spec_helper'

module FucdRbac
  UsersController.send(:include, FakeAuthorization)
  
  context "GET to fucd_rbac/users" do
    controller_name 'fucd_rbac/users'
    
    specify "should find all users" do
      @user = mock('user')
      User.should_receive(:find).with(:all).and_return([@user])
      
      get :index
      
      assigns(:users).should == [@user]
    end
  end
  
  context "GET to fucd_rbac/users/new" do
    controller_name 'fucd_rbac/users'
    
    setup do
      get :new
    end
    
    specify "should be successful" do
      response.should_be_success #TODO
    end
  end
  
  context "GET to fucd_rbac/users/edit/1" do
    controller_name 'fucd_rbac/users'
    
    specify "should get user with id=1" do
      @user = mock('user')
      User.should_receive(:find).with('1').and_return(@user)
      
      get :edit, :id => 1
      
      assigns(:user).should == @user
    end
  end
  
  context "GET to fucd_rbac/users/show/1" do
    controller_name 'fucd_rbac/users'
    
    specify "should get user with id=1" do
      @user = mock('user')
      User.should_receive(:find).with('1').and_return(@user)
      
      get :show, :id => 1
      
      assigns(:user).should == @user
    end
  end
  
  context "POST to fucd_rbac/users" do
    controller_name 'fucd_rbac/users'
    
    setup do
      @user = mock('user')
      @user.stub!(:to_s).and_return(1)
      User.stub!(:new).and_return(@user)
    end
    
    specify "should try to create new user" do
      @user.should_receive(:save)
      User.should_receive(:new).with("name" => "John Doe").and_return(@user)
      
      post :create, :user => { "name" => "John Doe" }
    end
    
    specify "should redirect to show new user after successful save" do
      @user.stub!(:save).and_return(true)
      
      controller.should_redirect_to :action => 'show', :id => 1
      
      post :create
    end
    
    specify "should render action 'new' after failed save" do
      @user.stub!(:save).and_return(false)
      
      controller.should_render :action => 'new'
      
      post :create
      
      assigns(:user).should == @user
    end
  end
  
  context "PUT to fucd_rbac/users/1" do
    controller_name 'fucd_rbac/users'
    
    setup do
      @user = mock('user')
      @user.stub!(:to_s).and_return(1)
      User.stub!(:find).and_return(@user)
    end
    
    specify "should try to update user with id=1" do
      @user.should_receive(:update_attributes).with("name" => "John Doe")
      User.should_receive(:find).with('1').and_return(@user)
      
      put :update, :id => 1, :user => { "name" => "John Doe" }
    end
    
    specify "should redirect to show user with id=1 after successful update" do
      @user.should_receive(:update_attributes).and_return(true)
      
      controller.should_redirect_to :action => 'show', :id => 1
      
      put :update, :id => 1
    end
    
    specify "should render action 'edit' after failed update" do
      @user.should_receive(:update_attributes).and_return(false)
      
      controller.should_render :action => 'edit'
      
      put :update, :id => 1
      
      assigns(:user).should == @user
    end
  end
  
  context "DELETE to fucd_rbac/users/1" do
    controller_name 'fucd_rbac/users'
    
    setup do
      @user = mock('user')
      @user.stub!(:destroy)
      User.stub!(:find).and_return(@user)
    end
    
    specify "should delete user with id=1" do
      @user.should_receive(:destroy)
      User.should_receive(:find).with('1').and_return(@user)
      
      delete :destroy, :id => 1
    end
    
    specify "should redirect to action 'index'" do
      controller.should_redirect_to :action => 'index'
      
      delete :destroy, :id => 1
    end
  end
end
