require File.dirname(__FILE__) + '/../../spec_helper'

module Railfrog
  context "GET to /railfrog/users" do
    include SpecHelpers
    controller_name 'railfrog/users'
  
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
  
  context "GET to /railfrog/users/new" do
    controller_name 'railfrog/users'
    
    setup do
      get :new
    end
    
    specify "should create a new user" do
      response.should_be_success
    end
  end
  
  context "GET to /railfrog/users/edit/1" do
    include SpecHelpers
    controller_name 'railfrog/users'
    
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
  
  context "GET to /railfrog/users/show/1" do
    include SpecHelpers
    controller_name 'railfrog/users'
    
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
  
  context "POST to /railfrog/users with valid attributes" do
    include SpecHelpers
    controller_name 'railfrog/users'
    
    setup do
      User.any_instance.stubs(:save).returns(user_count = 1)
      User.stubs(:count).returns(user_count || 0)
      post :create, :user => required_user_attributes
    end
    
    specify "should create new user 'johndoe'" do
      User.count.should_be 1
    end
    
    specify "should redirect to show new user" do
      response.should_be_redirect
      response.redirect_url.should_equal railfrog_user_url(assigns(:user))
    end
  end
  
  context "PUT to /railfrog/users/1" do
    include SpecHelpers
    controller_name 'railfrog/users'
    
    setup do
      @user = User.new required_user_attributes
      @user.stubs(:save).returns(true)
      User.stubs(:find).with { |id| id.to_i == 1 }.returns(@user)
      put :update, :id => 1, :user => { :email => 'johnsnewaddress@doe-enterprises.com'} 
    end
    
    specify "should update user 'johndoe'" do
      User.find(1).email.should_equal 'johnsnewaddress@doe-enterprises.com'
    end
    
    specify "should redirect to /railfrog/users/show/1" do
      response.should_be_redirect
      response.redirect_url.should_equal railfrog_user_url(assigns(:user))
    end
  end
  
  context "DELETE to /railfrog/users/1" do
    include SpecHelpers
    controller_name 'railfrog/users'
    
    setup do
      @user = User.new required_user_attributes
      @user.stubs(:destroy).returns(user_count = 0)
      User.stubs(:count).returns(user_count || 1)
      User.stubs(:find).with('1').returns(@user)
      delete :destroy, :id => 1
    end
    
    specify "should delete user 'johndoe'" do
      User.count.should_be 0
    end
    
    specify "should redirect to /railfrog/users" do
      response.should_be_redirect
      response.redirect_url.should_equal railfrog_users_url
    end
  end
end
