require File.dirname(__FILE__) + '/../../spec_helper'

module FucdRbac
  MembershipsController.send(:include, FakeAuthorization)
  
  context "GET to fucd_rbac/memberships with :user_id" do
    controller_name 'fucd_rbac/memberships'
    
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
  
  context "GET to fucd_rbac/memberships with :role_id" do
    controller_name 'fucd_rbac/memberships'
    
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
  
  context "GET to fucd_rbac/memberships without :user_id and :role_id" do
    controller_name 'fucd_rbac/memberships'
    
    specify "should not be possible" do
      lambda { get :edit }.should_raise
    end
  end
  
  context "PUT to fucd_rbac/memberships with :user_id" do
    include SpecHelpers
    controller_name 'fucd_rbac/memberships'
    
    setup do
      @user = User.create required_user_attributes
      @roles = [Role.create(required_role_attributes), Role.create(required_role_attributes.merge({:name => 'admin'}))]
      put :update, :user_id => @user.id, :memberships => { @roles[0].id => '0', @roles[1].id => '1' }
    end
    
    specify "should redirect to show user" do
      response.should_be_redirect
      response.redirect_url.should_equal fucd_rbac_user_url(@user.id)
    end
    
    specify "should create a membership relation between user and second role" do
      Membership.find_by_user_id_and_role_id(@user.id, @roles[1].id).should_not_be nil
    end
  end
  
  context "PUT to fucd_rbac/memberships with :role_id" do
    include SpecHelpers
    controller_name 'fucd_rbac/memberships'
    
    setup do
      @role = Role.create required_role_attributes
      @users = [User.create(required_user_attributes), User.create(required_user_attributes.merge({:username => 'janedoe'}))]
      put :update, :role_id => @role.id, :memberships => { @users[0].id => '0', @users[1].id => '1' }
    end
    
    specify "should redirect to show role" do
      response.should_be_redirect
      response.redirect_url.should_equal fucd_rbac_role_url(@role.id)
    end
    
    specify "should create a membership relation between second user and role" do
      Membership.find_by_user_id_and_role_id(@users[1].id, @role.id).should_not_be nil
    end
  end
  
  context "PUT to fucd_rbac/memberships without :user_id and :role_id" do
    controller_name 'fucd_rbac/memberships'
    
    specify "should not be possible" do
      lambda { put :update }.should_raise
    end
  end
end
