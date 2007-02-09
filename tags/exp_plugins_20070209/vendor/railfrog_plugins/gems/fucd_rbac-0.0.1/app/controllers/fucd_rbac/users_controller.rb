module FucdRbac
  class UsersController < ::Railfrog::BaseController
    before_filter :find_user, :only => [ :show, :edit, :update, :destroy ]
    
    def index
      @users = User.find(:all)
      
      respond_to do |format|
        format.html
        format.xml  { render :xml => @users.to_xml }
      end
    end
    
    def show
      respond_to do |format|
        format.html
        format.xml  { render :xml => @user.to_xml }
      end
    end
    
    def new
      @user = User.new
    end
    
    def edit
    end
    
    def create
      @user = User.new(params[:user])
      
      respond_to do |format|
        if @user.save
          flash[:notice] = 'User was successfully created.'
          
          format.html { redirect_to fucd_rbac_user_url(@user) }
          format.xml do
            headers["Location"] = fucd_rbac_user_url(@user)
            render :nothing => true, :status => "201 Created"
          end
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @user.errors.to_xml }
        end
      end
    end
    
    def update
      respond_to do |format|
        if @user.update_attributes(params[:user])
          flash[:notice] = 'User was successfully updated.'
          
          format.html { redirect_to fucd_rbac_user_url(@user) }
          format.xml  { render :nothing => true }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @user.errors.to_xml }
        end
      end
    end
    
    def destroy
      @user.destroy
      
      flash[:notice] = 'User was successfully deleted.'
      
      respond_to do |format|
        format.html { redirect_to fucd_rbac_users_url }
        format.xml  { render :nothing => true }
      end
    end
    
    protected
    
      def find_user
        @user = User.find(params[:id])
      end
  end
end
