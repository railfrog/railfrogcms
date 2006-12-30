module FucdRbac
  class RolesController < ::Railfrog::BaseController
    before_filter :find_role, :only => [:show, :edit, :update, :destroy]
    
    def index
      @roles = Role.find(:all)
      
      respond_to do |format|
        format.html
        format.xml  { render :xml => @roles.to_xml }
      end
    end
    
    def show
      respond_to do |format|
        format.html
        format.xml  { render :xml => @role.to_xml }
      end
    end
  
    def new
      @role = Role.new
    end
    
    def edit
    end
    
    def create
      @role = Role.new(params[:role])
      
      respond_to do |format|
        if @role.save
          flash[:notice] = 'Role was successfully created.'
          
          format.html { redirect_to fucd_rbac_role_url(@role) }
          format.xml do
            headers["Location"] = fucd_rbac_role_url(@role)
            render :nothing => true, :status => "201 Created"
          end
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @role.errors.to_xml }
        end
      end
    end
    
    def update
      respond_to do |format|
        if @role.update_attributes(params[:role])
          flash[:notice] = 'Role was successfully updated.'
          
          format.html { redirect_to fucd_rbac_role_url(@role) }
          format.xml  { render :nothing => true }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @role.errors.to_xml }        
        end
      end
    end
    
    def destroy
      @role.destroy
      
      respond_to do |format|
        format.html { redirect_to fucd_rbac_roles_url }
        format.xml  { render :nothing => true }
      end
    end
    
    protected
    
      def find_role
        @role = Role.find(params[:id])
      end
  end
end
