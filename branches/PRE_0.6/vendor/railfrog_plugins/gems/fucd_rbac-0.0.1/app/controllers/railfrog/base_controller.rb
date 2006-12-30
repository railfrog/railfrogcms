module Railfrog
  class BaseController < ::ApplicationController
    before_filter :authenticate
    
    protected
    
    def authenticated?
      ! session[:fucd_rbac_login_id].nil?
    end
    
    def authenticate
      unless authenticated?
        session[:return_to] = request.request_uri
        flash[:error] = "You have to be logged in to perform this action!"
        
        respond_to do |format|
          format.html { redirect_to fucd_rbac_login_url }
          # TODO: Add HTTP Authentication for the XML response (see http://wiki.rubyonrails.org/rails/pages/HowtoAuthenticateWithHTTP)
          format.xml  { render :nothing => true, :status => 401 } # TODO: Correct status code?
        end
      else
        controller, action = request.path_parameters.values_at(:controller, :action)
        unless FucdRbac::Login.find(session[:fucd_rbac_login_id]).user.has_permission_for?(controller, action)
          flash[:error] = "You do not have sufficient rights to perform this action!"
          
          respond_to do |format|
            format.html { render :text => '', :layout => true, :status => 403 } # TODO: Correct status code?
            format.xml  { render :nothing => true, :status => 403 } # TODO: Correct status code?
          end
        end
      end
    end
  end
end
