module FucdRbac
  class LoginController < ::Railfrog::BaseController
    layout 'login'
    
    before_filter :before_create, :only => [:create]
    before_filter :before_destroy, :only => [:destroy]
    
    def new
    end
    
    def create
      respond_to do |format|
        @login = Login.new(params[:login])
        
        if @login.save
          session[:fucd_rbac_login_id] = @login.id
          return_to = session[:return_to] || { :action => :new }#FIXME
          session[:return_to] = nil
          
          flash[:notice] = 'You have successfully logged in.'
  
          format.html { redirect_to return_to }
          format.xml do
            headers["Location"] = return_to
            render :nothing => true, :status => "201 Created" # TODO: Find better HTTP-status message for this
          end
        else
          flash[:error] = @login.errors[:base] #FIXME: Use @login.errors instead of flash in view
          format.html { render :action => "new" }
          format.xml  { render :xml => @login.errors.to_xml }
        end
      end
    end
    
    def destroy
      begin
        @login = Login.find(session[:fucd_rbac_login_id])
        @login.destroy
      ensure
        reset_session
      end
      
      flash[:notice] = 'You have successfully logged out.'
      
      respond_to do |format|        
        format.html { redirect_to fucd_rbac_login_url }
        format.xml  { render :nothing => true }
      end
    end
    
    private
      def before_create
        if session[:fucd_rbac_login_id]
          flash[:error] = 'You are already logged in!'
          
          respond_to do |format|
            format.html { redirect_to fucd_rbac_login_url } #:back ! #FIXME
  #          format.xml  {}
          end
        end
      end
      
      def before_destroy
        unless session[:fucd_rbac_login_id]
          flash[:error] = 'You have to be logged in to log out!'
          
          respond_to do |format|
            format.html { redirect_to fucd_rbac_login_url }
  #          format.xml  {}
          end
        end
      end
  end
end
