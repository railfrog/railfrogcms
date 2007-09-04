require File.dirname(__FILE__) + '/../../spec_helper'

module FucdRbac
  context "A login (in general)" do
    setup do
      @login = Login.new
    end
    
    specify "should be invalid without a user" do
      @login.should_not_be_valid
    end
    
    specify "should not be saved on destroy" do
      @login.destroy
      @login.should_be_new_record
    end
    
    specify "cannot set user by mass-assignement" do
      old_user = @login.user = User.new(:username => 'johndoe')
      @login.attributes = { :user => User.new(:username => 'janedoe') }
      @login.user.should_be old_user
    end
  end
  
  context "A new login with valid credentials" do
    setup do
      @user = User.new
      @user.stubs(:id).returns(1)
      User.stubs(:find_with_credentials).with('johndoe', 'abcdefg').returns(@user)
      @login = Login.new(:username => 'johndoe', :password => 'abcdefg')
    end
    
    specify "should be valid" do
      @login.should_be_valid
    end
  end
  
  context "A new login with invalid credentials" do
    setup do
      User.stubs(:find_with_credentials).returns(nil)
      @login = Login.new(:username => 'johndoe', :password => 'abcdefg')
    end
    
    specify "should be invalid" do
      @login.should_not_be_valid
    end
  end
  
  context "A new login without credentials" do
    setup do
      User.stubs(:find_with_credentials).returns(nil)
      @login = Login.new
    end
    
    specify "should be invalid" do
      @login.should_not_be_valid
    end
  end
  
  context "A created login" do
    setup do
      @user = User.new
      @user.stubs(:id).returns(1)
      User.stubs(:find_with_credentials).with('johndoe', 'abcdefg').returns(@user)
      @mock_time = Time.utc(2000, 1, 1, 0, 0, 0, 0)
      Time.stubs(:now).returns(@mock_time)
      @login = Login.create(:username => 'johndoe', :password => 'abcdefg')
    end
    
    specify "should have a login time" do
      @login.logged_in_at.should_equal @mock_time
    end
    
    specify "should have no logout time" do
      @login.logged_out_at.should_be nil
    end
  end
  
  context "A destroyed login" do
    setup do
      @user = User.new
      @user.stubs(:id).returns(1)
      User.stubs(:find_with_credentials).with('johndoe', 'abcdefg').returns(@user)
      @mock_time = Time.utc(2000, 1, 1, 0, 0, 0, 0)
      Time.stubs(:now).returns(@mock_time)
      @login = Login.create(:username => 'johndoe', :password => 'abcdefg').destroy
    end
    
    specify "should have a logout time" do
      @login.logged_out_at.should_equal @mock_time
    end
    
    specify "should not be deleted" do
      Login.find(@login.id).should_not_be nil
    end
    
    specify "should be frozen" do
      @login.should_be_frozen
    end
  end
end
