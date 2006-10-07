class UserController < ApplicationController
  require 'digest/sha1'
  layout 'admin'

  # Security
  before_filter :ensure_logged_in, :only => [ :index, :list, :new, :create ]


  # Login Authentication
  def authenticate
    encrypted_password = SHA1.hexdigest params[:password]
    user = User.find_by_email_and_password params[:email], encrypted_password
    if user
      session[:user_id] = user.id
      redirect_to rf_admin_url
    else
      flash[:error] = 'Log In Failed'
      redirect_to :action => 'login'
    end
  end


  # Login
  def login
    render :layout => 'default'
  end


  # Logout
  # ToDo: Return URI
  def logout
    reset_session
    flash[:notice] = 'Logout Sucessful'
    redirect_to :action => 'login'
  end


  # User Administration
  def index
    @users = User.find(:all)
  end


  def new
    @user = User.new
  end


  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User Successfully Created'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
end