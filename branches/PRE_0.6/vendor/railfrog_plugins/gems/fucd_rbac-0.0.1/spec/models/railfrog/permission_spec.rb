require File.dirname(__FILE__) + '/../../spec_helper'

module Railfrog
  context "A permission (in general)" do
    include SpecHelpers
    
    setup do
      @permission = Permission.new
    end
    
    specify "should be invalid without a role" do
      @permission.should_not_be_valid
      @permission.errors.on(:role_id).should_not_be nil
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
  end
end
