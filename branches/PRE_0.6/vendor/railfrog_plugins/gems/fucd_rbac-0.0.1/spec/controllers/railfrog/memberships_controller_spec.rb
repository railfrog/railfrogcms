require File.dirname(__FILE__) + '/../../spec_helper'

module Railfrog
  context "GET to /railfrog/memberships with :user_id" do
    controller_name 'railfrog/memberships'
    
    setup do
      ids = [1,2]
      Role.any_instance.stubs(:id).returns(ids.shift)
      @roles = [Role.new, Role.new]
      User.stubs(:find).with('1').returns(@user = User.new)
      Role.stubs(:find).with(:all).returns(@roles)
      get :edit, :user_id => 1
    end
    
    specify "should be successful" do
      response.should_be_success
    end
    
    specify "should assign @user with the user with ID=1" do
      assigns(:user).should_equal @user
    end
    
    specify "should assign @roles with all roles" do
      assigns(:roles).should_equal @roles
    end
  end
  
  context "GET to /railfrog/memberships with :role_id" do
    controller_name 'railfrog/memberships'
    
    setup do
      ids = [1,2]
      User.any_instance.stubs(:id).returns(ids.shift)
      @users = [User.new, User.new]
      User.stubs(:find).with(:all).returns(@users)
      Role.stubs(:find).with('1').returns(@role = Role.new)
      get :edit, :role_id => 1
    end
    
    specify "should be successful" do
      response.should_be_success
    end
    
    specify "should assign @users with all roles" do
      assigns(:users).should_equal @users
    end
    
    specify "should assign @role with the role with ID=1" do
      assigns(:role).should_equal @role
    end
  end
  
  context "GET to /railfrog/memberships without :user_id and :role_id" do
    controller_name 'railfrog/memberships'
    
    specify "should not be possible" do
      lambda { get :edit }.should_raise
    end
  end
  
  context "PUT to /railfrog/memberships with :user_id" do
    controller_name 'railfrog/memberships'
    
    setup do
      put :update, :user_id => 1, :memberships => { '1' => '0', '2' => '1' }
    end
    
    specify "should redirect to ???" do
      response.should_be_redirect
#      response.redirect_url.should_equal 
    end
    
    specify "should create a membership relation between user with ID=1 and role with ID=2" do
      Membership.find_by_user_id_and_role_id(1, 2).should_not_be nil
    end
  end
  
  context "PUT to /railfrog/memberships with :role_id" do
    controller_name 'railfrog/memberships'
    
    setup do
      put :update, :role_id => 1, :memberships => { '1' => '0', '2' => '1' }
    end
    
    specify "should redirect to ???" do
      response.should_be_redirect
#      response.redirect_url.should_equal 
    end
    
    specify "should create a membership relation between user with ID=2 and role with ID=1" do
      Membership.find_by_user_id_and_role_id(2, 1).should_not_be nil
    end
  end
  
  context "PUT to /railfrog/memberships without :user_id and :role_id" do
    controller_name 'railfrog/memberships'
    
    specify "should not be possible" do
      lambda { put :update }.should_raise
    end
  end
end
