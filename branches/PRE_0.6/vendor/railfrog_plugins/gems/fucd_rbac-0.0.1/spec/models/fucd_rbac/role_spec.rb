require File.dirname(__FILE__) + '/../../spec_helper'

module FucdRbac
  context "A role (in general)" do
    include SpecHelpers
    
    setup do
      @role = Role.new
    end
    
    specify "should be invalid without a name" do
      @role.attributes = required_role_attributes.except(:name)
      @role.should_not_be_valid
      @role.errors.on(:name).should_not_be nil
    end
    
    specify "should have a unique name" do
      Role.stubs(:find).returns([@user])
      @role.should_not_be_valid
      @role.errors.on(:name).should_not_be nil
    end
  end
  
  context "A role with the full set of required attributes" do
    include SpecHelpers
    
    setup do
      @role = Role.new required_role_attributes
    end
    
    specify "should be valid" do
      @role.should_be_valid
    end
  end
  
  context "A saved role with an associated user" do
    include SpecHelpers
    
    setup do
      @role = Role.create required_role_attributes
      @user = User.create required_user_attributes
      @role.users << @user
    end
    
    specify "should have 1 associated user" do
      @role.should_have(1).users
    end
    
    specify "should 'have' the associated user" do
      @role.has_user?(@user).should_be true
    end
    
    specify "should remove membership of user in role when removing role" do
      @role.destroy
      Membership.should_have(0).records
    end
  end
  
  context "A saved role with a permission" do
    include SpecHelpers
    
    setup do
      @role = Role.create required_role_attributes
      @permission = Permission.new required_permission_attributes
      @role.permissions << @permission
    end
    
    specify "should have 1 permission" do
      @role.should_have(1).permissions
    end
    
    specify "should remove all associated permissions when removing role" do
      @role.destroy
      Permission.should_have(0).records
    end
    
    specify "should grant permission for action 'show' of controller 'people'" do
      @permission.stubs(:grants?).with('people', 'show').returns(true)
      @role.grants_permission_for?('people', 'show').should_be true
    end
    
    specify "should not grant permission for action 'edit' of controller 'people'" do
      @permission.stubs(:grants?).with('people', 'edit').returns(false)
      @role.grants_permission_for?('people', 'edit').should_be false
    end
  end
end
