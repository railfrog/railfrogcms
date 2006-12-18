require File.dirname(__FILE__) + '/../../spec_helper'

module FucdRbac
  MembershipsController.send(:include, FakeAuthorization)
  
  context "GET to fucd_rbac/memberships" do
    controller_name 'fucd_rbac/memberships'
    
    setup do
      @user = mock('user')
      @role = mock('role')
    end
    
    specify "should get user with id=1 and all roles if given user_id=1" do
      User.should_receive(:find).with('1').and_return(@user)
      Role.should_receive(:find).with(:all).and_return([@role, @role])
      
      get :edit, :user_id => 1
      
      assigns(:user).should == @user
      assigns(:roles).should == [@role, @role]
    end
    
    specify "should get role with id=1 and all users if given role_id=1" do
      Role.should_receive(:find).with('1').and_return(@role)
      User.should_receive(:find).with(:all).and_return([@user, @user])
      
      get :edit, :role_id => 1
      
      assigns(:users).should == [@user, @user]
      assigns(:role).should == @role
    end
    
    specify "should not be possible if given neither :user_id nor :role_id" do #TODO: better specify text
      lambda { get :edit }.should_raise #TODO raise ok?
    end
  end
  
  context "PUT to fucd_rbac/memberships" do
    controller_name 'fucd_rbac/memberships'
    
    setup do
      @membership = mock('membership')
    end
    
    specify "should create a membership relation between 'user 1' and 'role 2', redirect to show 'user 1'" do
      Membership.should_receive(:find_or_create_by_user_id_and_role_id).with('1', '2')
      Membership.should_receive(:find_by_user_id_and_role_id).with('1', '1').and_return(nil)
      
      controller.should_redirect_to :controller => 'users', :action => 'show', :id => 1
      
      put :update, :user_id => '1', :memberships => { '1' => '0', '2' => '1' }
    end
    
    specify "should destroy the membership relation between 'user 2' and 'role 1', redirect to show 'user 1'" do
      Membership.should_receive(:find_by_user_id_and_role_id).with('2', '1').and_return(@membership)
      @membership.should_receive(:destroy)
      
      controller.should_redirect_to :controller => 'users', :action => 'show', :id => 2

      put :update, :user_id => '2', :memberships => { '1' => '0' }
    end
    
    specify "should create a membership relation between 'role 1' and 'user 2', redirect to show role" do
      Membership.should_receive(:find_or_create_by_user_id_and_role_id).with('2', '1')
      Membership.should_receive(:find_by_user_id_and_role_id).with('1', '1').and_return(nil)
      
      controller.should_redirect_to :controller => 'roles', :action => 'show', :id => 1
      
      put :update, :role_id => '1', :memberships => { '1' => '0', '2' => '1' }
    end
    
    specify "should destroy the membership relation between 'role 2' and 'user 1', redirect to show role" do
      Membership.should_receive(:find_by_user_id_and_role_id).with('1', '2').and_return(@membership)
      @membership.should_receive(:destroy)
      
      controller.should_redirect_to :controller => 'roles', :action => 'show', :id => 2

      put :update, :role_id => '2', :memberships => { '1' => '0' }
    end
    
    specify "should not be possible if given neither :user_id nor :role_id" do #TODO: better specify text
      lambda { put :update }.should_raise #TODO raise ok?
    end
  end
end
