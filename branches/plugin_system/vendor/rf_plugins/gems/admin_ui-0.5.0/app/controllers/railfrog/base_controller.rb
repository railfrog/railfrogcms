class Railfrog::BaseController < ApplicationController
  layout 'rf_admin'

  before_filter :ensure_logged_in, :except => [ :login, :logout, :authenticate ]

  helper_method :logged_in?
  
  # Check a User is Logged In
  def logged_in?
    session[:user_id]
  end

  # Ensure a User is Logged In
  def ensure_logged_in
    return true if logged_in?
    flash[:error] = 'Please Log In'
    redirect_to_login
    return false
  end
  
  # Re-Direct an Un-Authenticated User to Login
  # ToDo: Return URI
  def redirect_to_login
    redirect_to :controller => 'railfrog/users', :action => 'login'
  end
end
