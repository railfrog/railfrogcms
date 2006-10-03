require File.dirname(__FILE__) + '/../../spec_helper'

module Railfrog
  context "GET to /railfrog/login" do
    controller_name 'railfrog/login'
    
    setup do
      get :new
    end
    
    specify "should be successful" do
      response.should_be_success
    end
  end
  
  context "POST to /railfrog/login/create with valid credentials" do
    controller_name 'railfrog/login'
    
    setup do
      valid_credentials = Hash.new(:username => 'johndoe', :password => 'abcdefg')
      @login = Login.new
      @login.stubs(:save).returns(true)
      @login.stubs(:id).returns(1)
      Login.stubs(:new).with(valid_credentials).returns(@login)
      post :create, :login => valid_credentials
    end
    
    specify "should login user 'johndoe'" do
      session[:railfrog_login_id].should_not_be nil
      #...
    end
    
    specify "should display notice" do
      flash[:notice].should_not_be nil
    end
    
    specify "should redirect to ??" do
      response.should_be_redirect
#      response.redirect_url.should_equal 
    end
  end
  
  context "POST to /railfrog/login/create with valid credentials and set session[:return_to]" do
    controller_name 'railfrog/login'
    
    setup do
      valid_credentials = Hash.new(:username => 'johndoe', :password => 'abcdefg')
      @login = Login.new
      @login.stubs(:save).returns(true)
      @login.stubs(:id).returns(1)
      Login.stubs(:new).with(valid_credentials).returns(@login)
      request.session[:return_to] = 'http://test.host/where_i_came_from'
      post :create, :login => valid_credentials
    end
    
    specify "should redirect to last location" do
      response.should_be_redirect
      response.redirect_url.should_equal 'http://test.host/where_i_came_from'
    end
  end
  
  context "POST to /railfrog/login/create with invalid credentials" do
    controller_name 'railfrog/login'
    
    setup do
      @login = Login.new
      @login.stubs(:save).returns(false)
      @login.valid?
      Login.stubs(:new).returns(@login)
      post :create, :login => { :username => 'janedoe', :password => 'invalid_password' }
    end
    
    specify "should not login 'janedoe'" do
      session[:railfrog_login_id].should_be nil
      #...
    end
    
    specify "should display error" do
      flash[:error].should_not_be nil
    end
    
    specify "should render 'new'" do
      response.should_render :new
    end
  end
  
  
  context "POST to /railfrog/login/create when logged in" do
    controller_name 'railfrog/login'
    
    setup do
      request.session[:railfrog_login_id] = 1
      post :create
    end
    
    specify "should display error" do
      flash[:error].should_not_be nil
    end
    
    #...
  end
  
  context "DELETE to /railfrog/login/destroy when logged in" do
    controller_name 'railfrog/login'
    
    setup do
      Login.stubs(:find).returns(Login.new)
      request.session[:railfrog_login_id] = 1
      delete :destroy
    end
    
    specify "should logout user 'johndoe'" do
      session[:railfrog_login_id].should_be nil
      #...
    end
    
    specify "should display notice" do
      flash[:notice].should_not_be nil
    end
    
    specify "should redirect back to login" do
      response.should_be_redirect
      response.redirect_url.should_equal 'http://test.host/railfrog/login'
    end
  end
  
  context "DELETE to /railfrog/login/destroy when not logged in" do
    controller_name 'railfrog/login'
    
    setup do
      delete :destroy
    end
    
    specify "should display error" do
      flash[:error].should_not_be nil
    end
    
    specify "should redirect to ???" do
      response.should_be_redirect
#      response.redirect_url.should_equal
    end
  end
end
