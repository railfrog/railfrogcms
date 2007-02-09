require File.expand_path(File.dirname(__FILE__) + '/../../../../../spec/spec_helper')

module FucdRbac
  module SpecHelpers
    def required_user_attributes
      { :username => 'johndoe',
        :first_name => 'John',
        :last_name => 'Doe',
        :email => 'john@doe.com',
        :password => 'abcdefg' }
    end
    
    def required_membership_attributes
      { :user_id => 1,
        :role_id => 2 }
    end
    
    def required_role_attributes
      { :name => 'editor' }
    end
    
    def required_permission_attributes
      { :role_id => 1,
        :controller => 'foo',
        :action => '.*' }
    end
  end
  
  module FakeAuthorization
    protected
    
    def authenticate
      true
    end
  end
end
