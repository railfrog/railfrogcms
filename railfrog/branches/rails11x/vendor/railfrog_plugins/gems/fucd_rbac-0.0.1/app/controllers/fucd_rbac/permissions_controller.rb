module FucdRbac
  class PermissionsController < ::Railfrog::BaseController
    before_filter :authenticate
    
    before_filter :find_permission, :only => [ :edit, :update, :destroy ]
    
    def index
      @permissions = Permission.find_all_by_role_id(params[:role_id])
      
      respond_to do |format|
        format.html
        format.xml  { render :xml => @permissions.to_xml }
      end
    end
    
    def new
      @permission = Permission.new
    end
    
    def edit
    end
    
    def create
      @permission = Role.find(params[:role_id]).permissions.build(params[:permission])
      
      respond_to do |format|
        if @permission.save
          flash[:notice] = 'Permission was successfully created.'
          
          format.html { redirect_to fucd_rbac_permissions_url(params[:role_id]) }
          format.xml do
            headers["Location"] = fucd_rbac_permissions_url
            render :nothing => true, :status => "201 Created"
          end
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @permission.errors.to_xml }
        end
      end
    end
    
    def update
      respond_to do |format|
        if @permission.update_attributes(params[:permission])
          flash[:notice] = 'Permission was successfully updated.'
          
          format.html { redirect_to fucd_rbac_permissions_url }
          format.xml  { render :nothing => true }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @permission.errors.to_xml }
        end
      end
    end
    
    def destroy
      @permission.destroy
      
      flash[:notice] = 'Permission was successfully deleted.'
      
      respond_to do |format|
        format.html { redirect_to fucd_rbac_permissions_url }
        format.xml  { render :nothing => true }
      end
    end
    
    protected
    
      def find_permission
        @permission = Permission.find_by_id_and_role_id(params[:id], params[:role_id])
      end
  end
end
