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
  
  context "A new login" do
    specify "should be valid if given valid credentials" do
      @user = User.new
      @user.stub!(:id).and_return(1)
      User.should_receive(:find_with_credentials).with('johndoe', 'abcdefg').and_return(@user)
      Login.new(:username => 'johndoe', :password => 'abcdefg').should_be_valid
    end
    
    specify "should be invalid if given invalid credentials" do
      User.should_receive(:find_with_credentials).with('johndoe', 'abcdefg').and_return(nil)
      Login.new(:username => 'johndoe', :password => 'abcdefg').should_not_be_valid
    end
    
    specify "should be invalid if given no credentials" do
      User.stub!(:find_with_credentials).and_return(nil)
      Login.new.should_not_be_valid
    end
  end
  
  context "A created login" do
    setup do
      @user = User.new
      @user.stub!(:id).and_return(1)
      User.should_receive(:find_with_credentials).with('johndoe', 'abcdefg').and_return(@user)
      @mock_time = Time.utc(2000, 1, 1, 0, 0, 0, 0)
      Time.stub!(:now).and_return(@mock_time)
      @login = Login.create(:username => 'johndoe', :password => 'abcdefg')
    end
    
    specify "should have a login time" do
      @login.logged_in_at.should == @mock_time
    end
    
    specify "should have no logout time" do
      @login.logged_out_at.should_be nil
    end
    
    teardown do
      Login.delete(@login.id)
    end
  end
  
  context "A destroyed login" do
    setup do
      @user = User.new
      @user.stub!(:id).and_return(1)
      User.should_receive(:find_with_credentials).with('johndoe', 'abcdefg').and_return(@user)
      @mock_time = Time.utc(2000, 1, 1, 0, 0, 0, 0)
      Time.stub!(:now).and_return(@mock_time)
      @login = Login.create(:username => 'johndoe', :password => 'abcdefg').destroy
    end
    
    specify "should have a logout time" do
      @login.logged_out_at.should == @mock_time
    end
    
    specify "should not be deleted" do
      Login.find(@login.id).should_not_be nil
    end
    
    specify "should be frozen" do
      @login.should_be_frozen
    end
    
    teardown do
      Login.delete(@login.id)
    end
  end
end
