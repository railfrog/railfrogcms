class AccountController < ApplicationController
  verify  :only => [:create, :create_with_ajax],
          :params => 'newuser',
          :method => :post,
          :redirect_to => { :action => 'new' }

  def new
    @newuser = User.new
    @error = ''
    final_render('account/new')
  end
  
  def login
    @inuser = {}
    final_render('account/login')
  end
  
  def logout
    User.logout
    final_render('account/logout')
  end
  
  def do_login
    final_render('account/logged_in') if process_login
  end
  
  def do_login_with_ajax
    final_render('account/logged_in', :ajax => true) if process_login
  end
  
  def create
    final_render('account/create') if do_create
  end
  
  def create_with_ajax
    final_render('account/create', :ajax => true) if do_create
  end
  
  private
  def process_login
    @inuser = params[:inuser].clone
    @inuser.create_errors_object
    @inuser.errors.add_on_empty('login', @inuser.errors.build_error('login', 'cant_be_empty', 'system'))
    @inuser.errors.add_on_empty('password', @inuser.errors.build_error('password', 'cant_be_empty', 'system'))

    begin
      User.login(@inuser.login, @inuser.password) unless @inuser.errors.on('login')
    rescue UserDoesntExistException
      @inuser.errors.add('login', @inuser.errors.build_error('login', 'doesnt_exist'))
    rescue InvalidPasswordException
      @inuser.errors.add('password', @inuser.errors.build_error('password', 'is_invalid'))
    rescue NoSessionStoringHashException
      @inuser.errors.add('system_error', 'system_error'._t('system'))
    end
    
    if @inuser.errors.count > 0 then
      @errors = @inuser.errors
      flash.now[:error] = final_render('account/login_error', :string => true)
      final_render('account/login')
      return false
    end

    return true
  end
  
  def do_create
    params[:newuser][:password_confirmation] = Auth::hash(params[:newuser][:password_confirmation])
    @newuser = User.new(params[:newuser])
    unless @newuser.valid?
      @errors = @newuser.errors
      flash.now[:error] = final_render('account/new_error', :string => true)
      final_render('account/new')
      return false
    end
    @newuser.save!
    @newuser.add_role(Role.default)
    return true
  end
  
  def url_for_create_with_ajax
    url_for :controller => 'account', :action => 'create_with_ajax'
  end
  
  def url_for_create
    url_for :controller => 'account', :action => 'create'
  end
  
  def url_for_login_with_ajax
    url_for :controller => 'account', :action => 'do_login_with_ajax'
  end
  
  def url_for_login
    url_for :controller => 'account', :action => 'do_login'
  end
  
  helper_method :url_for_create_with_ajax, :url_for_create, :url_for_login, :url_for_login_with_ajax
end
