require File.dirname(__FILE__) + '/../../spec_helper'

module FucdRbac
  UsersController.send(:include, FakeAuthorization)
  
  context "GET to fucd_rbac/users" do
    include SpecHelpers
    controller_name 'fucd_rbac/users'
  
    setup do
      @user = User.new required_user_attributes
      User.stubs(:find).with(:all).returns([@user])
      get :index
    end
    
    specify "should find all users" do
      response.should_be_success
      assigns(:users).should_equal [@user]
    end
  end
  
  context "GET to fucd_rbac/users/new" do
    controller_name 'fucd_rbac/users'
    
    setup do
      get :new
    end
    
    specify "should be successful" do
      response.should_be_success
    end
  end
  
  context "GET to fucd_rbac/users/edit/1" do
    include SpecHelpers
    controller_name 'fucd_rbac/users'
    
    setup do
      @user = User.new required_user_attributes
      User.stubs(:find).with('1').returns(@user)
      get :edit, :id => 1
    end
    
    specify "should edit the user 'johndoe'" do
      response.should_be_success
      assigns(:user).should_equal @user
    end
  end
  
  context "GET to fucd_rbac/users/show/1" do
    include SpecHelpers
    controller_name 'fucd_rbac/users'
    
    setup do
      @user = User.new required_user_attributes
      @user.stubs(:id).returns(1)
      User.stubs(:find).with('1').returns(@user)
      get :show, :id => 1
    end
    
    specify "should show the user 'johndoe'" do
      response.should_be_success
      assigns(:user).should_equal @user
    end
  end
  
  context "POST to fucd_rbac/users with valid attributes" do
    include SpecHelpers
    controller_name 'fucd_rbac/users'
    
    setup do
      post :create, :user => required_user_attributes
    end
    
    specify "should create new user 'johndoe'" do
      User.count.should_be 1
    end
    
    specify "should redirect to show new user" do
      response.should_be_redirect
      response.redirect_url.should_equal fucd_rbac_user_url(assigns(:user))
    end
  end
  
  context "POST to fucd_rbac/users with invalid attributes" do
    include SpecHelpers
    controller_name 'fucd_rbac/users'
    
    setup do
      post :create, :user => required_user_attributes.except(:username)
    end
    
    specify "should not create a new user" do
      User.count.should_be 0
    end
    
    specify "should raise model errors" do
      assigns(:user).errors.should_not_be nil
    end
    
    specify "should render new" do
      response.should_render :new
    end
  end
  
  context "PUT to fucd_rbac/users/<id> with valid attributes" do
    include SpecHelpers
    controller_name 'fucd_rbac/users'
    
    setup do
      @user = User.create required_user_attributes
      put :update, :id => @user.id, :user => { :email => 'johnsnewaddress@doe-enterprises.com'} 
    end
    
    specify "should update user 'johndoe'" do
      User.find(@user.id).email.should_equal 'johnsnewaddress@doe-enterprises.com'
    end
    
    specify "should redirect to show user 'johndoe'" do
      response.should_be_redirect
      response.redirect_url.should_equal fucd_rbac_user_url(assigns(:user))
    end
  end
  
  context "PUT to fucd_rbac/users/<id> with invalid attributes" do
    include SpecHelpers
    controller_name 'fucd_rbac/users'
    
    setup do
      @user = User.create required_user_attributes
      put :update, :id => @user.id, :user => { :email => nil }
    end
    
    specify "should not update user 'johndoe'" do
      User.find(@user.id).email.should_equal @user.email
    end
    
    specify "should raise model errors" do
      assigns(:user).errors.should_not_be nil
    end
    
    specify "should render edit" do
      response.should_render :edit
    end
  end
    
  context "DELETE to fucd_rbac/users/<id>" do
    include SpecHelpers
    controller_name 'fucd_rbac/users'
    
    setup do
      @user = User.create required_user_attributes
      delete :destroy, :id => @user.id
    end
    
    specify "should delete user 'johndoe'" do
      User.count.should_be 0
    end
    
    specify "should redirect to index" do
      response.should_be_redirect
      response.redirect_url.should_equal fucd_rbac_users_url
    end
  end
end
