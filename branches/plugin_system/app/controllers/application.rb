class ApplicationController < ActionController::Base  
  # Change this to your RailFrog installation directory with no trailing forward slash
  # ToDo: Automatic Extraction from ENV
  $INSTALLATION_BASE_URL = "http://localhost:3000"
  
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
  end
  
  # Re-Direct an Un-Authenticated User to Login
  # ToDo: Return URI
  def redirect_to_login
    redirect_to :controller => 'users', :action => 'login'
  end
end