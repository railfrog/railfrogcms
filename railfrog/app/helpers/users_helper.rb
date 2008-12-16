module UsersHelper
  # Check a User is Logged In
  def logged_in?
    session[:user_id]
  end

  # Ensure a User is Logged In
  def ensure_logged_in
    return true if logged_in?

    if User.count > 0
      flash[:error] = :please_login.l('Please Log In')
      redirect_to :controller => 'users', :action => 'login'
    else
      flash[:error] = :please_create_admin_user.l('Please Create Admin User')
      redirect_to :controller => 'users', :action => 'new'
    end
    return false
  end
end
