require File.dirname(__FILE__) + '/../../spec_helper'

module FucdRbac
  context "A role (in general)" do
    include SpecHelpers
    
    setup do
      @role = Role.new
    end
    
    specify "should be invalid without a name" do
      @role.attributes = required_role_attributes.except(:name)
      @role.should_have(1).error_on(:name)
    end
    
    specify "should have a unique name" do
      @role.attributes = required_role_attributes
      Role.should_receive(:find).and_return([@role])
      @role.should_have(1).error_on(:name)
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
      @role.should_have_user(@user)
    end
    
    specify "should remove membership of user in role when removing role" do
      @role.destroy
      Membership.should_have(0).records
    end
    
    teardown do
      @role.destroy
      @user.destroy
    end
  end
  
  context "A saved role with a permission" do
    include SpecHelpers
    
    setup do
      @role = Role.create required_role_attributes
      @permission = mock('permission')
      @role.stub!(:permissions).and_return([@permission])
      @permission.stub!(:destroy)
    end
    
    specify "should have 1 permission" do
      @role.should_have(1).permissions
    end
    
    specify "should remove all associated permissions when removing role" do
      @role.destroy
      @permission.should_receive(:destroy)
    end
    
    specify "should grant permission for action 'show' of controller 'people'" do
      @permission.should_receive(:grants?).with('people', 'show').and_return(true)
      @role.grants_permission_for?('people', 'show').should_be true
    end
    
    specify "should not grant permission for action 'edit' of controller 'people'" do
      @permission.should_receive(:grants?).with('people', 'edit').and_return(false)
      @role.grants_permission_for?('people', 'edit').should_be false
    end
    
    teardown do
      @role.destroy
    end
  end
end
