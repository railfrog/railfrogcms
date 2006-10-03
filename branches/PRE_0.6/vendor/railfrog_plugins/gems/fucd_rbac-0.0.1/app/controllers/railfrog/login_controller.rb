class Railfrog::LoginController < Railfrog::BaseController
  skip_before_filter :authenticate
  
  before_filter :before_create, :only => [:create]
  before_filter :before_destroy, :only => [:destroy]
  
  def new
  end
  
  def create
    respond_to do |format|
      @login = Login.new(params[:login])
      
      if @login.save
        session[:railfrog_login_id] = @login.id
        return_to = session[:return_to] || { :action => :new }#FIXME
        session[:return_to] = nil
        
        flash[:notice] = 'You have successfully logged in.'

        format.html { redirect_to return_to }
#        format.xml do
#          headers["Location"] = return_to
#          render :nothing => true#, :status => "201 Created"
#        end
      else
        flash[:error] = @login.errors[:base] #FIXME: Use @login.errors instead of flash in view
        format.html { render :action => :new }
        format.xml  { render :xml => @login.errors.to_xml }
      end
    end
  end
  
  def destroy
    @login = Login.find(session[:railfrog_login_id])
    @login.destroy
    
    reset_session
    
    flash[:notice] = 'You have successfully logged out.'
    
    respond_to do |format|        
      format.html { redirect_to :action => :new }
      format.xml  { render :nothing => true }
    end
  end
  
  private
    def before_create
      if session[:railfrog_login_id]
        flash[:error] = 'You are already logged in!'
        
        respond_to do |format|
          format.html { redirect_to :action => :new } #:back ! #FIXME
#          format.xml  {}
        end
      end
    end
    
    def before_destroy
      unless session[:railfrog_login_id]
        flash[:error] = 'You have to be logged in to log out!'
        
        respond_to do |format|
          format.html { redirect_to :action => :new } #:back ? #FIXME
#          format.xml  {}
        end
      end
    end
end

# 	  def signup
# 	    redirect_to :action => "login" and return unless User.count.zero?
# 	
# 	    @user = User.new(params[:user])
# 	
# 	    if request.post? and @user.save
# 	      session[:user] = User.authenticate(@user.login, params[:user][:password])
# 	      flash[:notice]  = "Signup successful"
# 	      redirect_to :controller => "admin/general", :action => "index"
# 	      return
# 	    end
# 	  end
