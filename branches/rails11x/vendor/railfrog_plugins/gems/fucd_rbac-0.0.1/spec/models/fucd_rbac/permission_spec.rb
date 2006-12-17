require File.dirname(__FILE__) + '/../../spec_helper'

module FucdRbac
  context "A permission (in general)" do
    include SpecHelpers
    
    setup do
      @permission = Permission.new
    end
    
    specify "should be invalid without a role" do
      @permission.attributes = required_permission_attributes.except(:role_id)
      @permission.should_not_be_valid
      @permission.errors.on(:role_id).should_not_be nil
    end
    
    specify "should be invalid without a controller" do
      @permission.attributes = required_permission_attributes.except(:controller)
      @permission.should_not_be_valid
      @permission.errors.on(:controller).should_not_be nil
    end
    
    specify "should be invalid without an action" do
      @permission.attributes = required_permission_attributes.except(:action)
      @permission.should_not_be_valid
      @permission.errors.on(:action).should_not_be nil
    end
  end
  
  context "A permission with the full set of required attributes" do
    include SpecHelpers
    
    setup do
      @permission = Permission.new required_permission_attributes
    end
    
    specify "should be valid" do
      @permission.should_be_valid
    end
    
    #Better specs to test if match uses Regexp
    specify "should grant permission for action 'bar' of controller 'foo'" do
      @permission.should_grants('foo', 'bar')
    end
    
    specify "should grant permission for action 'blah' of controller 'foo'" do
      @permission.should_grants('foo', 'blah')
    end
  end
end
