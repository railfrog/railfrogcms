require File.dirname(__FILE__) + '/../../spec_helper'

module FucdRbac
  context "GET to /fucd_rbac/login" do
    controller_name 'fucd_rbac/login'
    
    setup do
      get :new
    end
    
    specify "should be successful" do
      response.should_be_success #TODO
    end
  end
  
  context "POST to /fucd_rbac/login/create" do
    controller_name 'fucd_rbac/login'
    
    setup do
      @login = mock('login')
      @login.stub!(:id).and_return(1)
      @login.stub!(:errors).and_return({})
      Login.stub!(:new).and_return(@login)
    end
    
    specify "should login if given valid credentials" do
      @login.should_receive(:save).and_return(true)
      
      post :create
      
      controller.should_be_authenticated
    end
    
    specify "should redirect to last location if given valid credentials and session[:return_to]" do
      @login.should_receive(:save).and_return(true)
      
      return_to = request.session[:return_to] = 'http://test.host/where_i_came_from'
      controller.should_redirect_to return_to
      
      post :create
    end
    
    specify "should not login if given invalid crentials" do
      @login.should_receive(:save).and_return(false)
      
      controller.should_render :action => 'new'
      
      post :create
      
      controller.should_not_be_authenticated
    end
    
    specify "should ... if logged in" do
      controller.stub!(:authenticated?).and_return(true)
      
      post :create
      
#      flash[:error].should_not_be nil
    end
  end
  
  context "DELETE to /fucd_rbac/login/destroy" do
    controller_name 'fucd_rbac/login'
    
    specify "should logout and redirect to action 'new' if logged in" do
      controller.stub!(:authenticated?).and_return(true)
      
      @login = mock('login')
      @login.should_receive(:destroy)
      Login.should_receive(:find).and_return(@login)
      
      controller.should_redirect_to :action => 'new'
      
      delete :destroy
      
      session[:fucd_rbac_login_id].should_be nil #controller.should_not_be_authenticated
#      flash[:notice].should_not_be nil
    end
    
    specify "should ... if not logged in" do
#      flash[:error].should_not_be nil
    end
  end
end
