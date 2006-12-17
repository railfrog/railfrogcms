require File.dirname(__FILE__) + '/../../spec_helper'
require 'digest/sha2'

module FucdRbac
  context "A user (in general)" do
    include SpecHelpers
    
    setup do
      @user = User.new
    end
    
    specify "should be invalid without a username" do
      @user.attributes = required_user_attributes.except(:username)
      @user.should_not_be_valid
      @user.errors.on(:username).should_not_be nil
    end
    
    specify "should be invalid without a first name" do
      @user.attributes = required_user_attributes.except(:first_name)
      @user.should_not_be_valid
      @user.errors.on(:first_name).should_not_be nil
    end
    
    specify "should be invalid without a last name" do
      @user.attributes = required_user_attributes.except(:last_name)
      @user.should_not_be_valid
      @user.errors.on(:last_name).should_not_be nil
    end
    
  ## TODO: Remove? -- This is done by validates_format_of thus next spec should be enough.
  #  specify "should be invalid without an email" do
  #    @user.attributes = required_user_attributes.except(:email)
  #    @user.should_not_be_valid
  #    @user.errors.on(:email).should_not_be nil
  #  end
    
    specify "should be invalid with invalid email address" do
      @user.attributes = required_user_attributes.except(:email)
      @user.email = 'invalid.email.address'
      @user.should_not_be_valid
      @user.errors.on(:email).should_not_be nil
      @user.email = 'user_9+filter@domain.museum'
      @user.should_be_valid
    end
    
    specify "should be invalid without a d" do
      @user.attributes = required_user_attributes.except(:password)
      @user.should_not_be_valid
      @user.errors.on(:password).should_not_be nil
    end
    
    specify "should be invalid if password is below 6 characters in length" do
      @user.attributes = required_user_attributes.except(:password)
      @user.password = 'abcde'
      @user.should_not_be_valid
    end
    
    specify "cannot change his salt by mass-assignement" do
      salt_before = @user.salt
      @user.attributes = { :salt => 'mynewsalt' }
      @user.salt.should_be salt_before
    end
  end
  
  context "A user with the full set of required attributes" do
    include SpecHelpers
    
    setup do
      @user = User.new required_user_attributes
    end
    
    specify "should be valid" do
      @user.should_be_valid
    end
    
    specify "should have a full name" do
      @user.full_name.should_equal "John Doe"
    end
    
    specify "should have a unique username" do
      User.stubs(:find).returns([@user])
      @user.should_not_be_valid
      @user.errors.on(:username).should_not_be nil
    end
  end
  
  context "A saved user" do
    include SpecHelpers
    
    setup do
      @mock_time = Time.utc(2000, 1, 1, 0, 0, 0, 0).to_s
      Time.stubs(:now).returns(@mock_time)
      @user = User.create required_user_attributes
    end
    
    specify "should have a salt" do
      @user.salt.should_equal Digest::SHA256.hexdigest(@mock_time)
    end
    
    specify "should have a salted password" do
      @user.password.should_equal Digest::SHA256.hexdigest('abcdefg' + @user.salt)
    end
    
    specify "should leave password as it is on update when no new password is provided" do
      old_password = @user.password
      @user.update_attributes(:username => 'Johnny')
      @user.password.should_equal old_password
    end
    
    specify "should update password on update when new password is provided" do
      old_password = @user.password
      @user.update_attributes(:password => 'qwerty')
      @user.password.should_not_equal old_password
    end
    
    specify "can be found with his decrypted credentials" do
      User.find_with_credentials(@user.username, required_user_attributes[:password]).should_equal @user
    end
    
    specify "cannot be found with wrong credentials" do
      User.find_with_credentials(@user.username, "foobar").should_be nil
    end
  end
  
  context "A saved user with a login" do
    include SpecHelpers
    
    setup do
      @user = User.create required_user_attributes
      @login = Login.new
      @user.logins << @login
    end
    
    specify "should have 1 login" do
      @user.should_have(1).logins
    end
    
    specify "should remove all associated logins when removing user" do
      @user.destroy
      Login.should_have(0).records
    end
  end
  
  context "A saved user with an associated role" do
    include SpecHelpers
    
    setup do
      @role = Role.create required_role_attributes
      @user = User.create required_user_attributes
      @user.roles << @role
    end
    
    specify "should have 1 associated role" do
      @user.should_have(1).roles
    end
    
    specify "should 'have' the associated role" do
      @user.has_role?(@role).should_be true
    end
    
    specify "should remove membership of user in role when removing user" do
      @user.destroy
      Membership.should_have(0).records
    end
    
    specify "should have permission for action 'show' of controller 'people'" do
      @role.stubs(:grants_permission_for?).with('people', 'show').returns(true)
      @user.has_permission_for?('people', 'show').should_be true
    end
    
    specify "should not have permission for action 'edit' of controller 'people'" do
      @role.stubs(:grants_permission_for?).with('people', 'edit').returns(false)
      @user.has_permission_for?('people', 'edit').should_be false
    end
  end
end
