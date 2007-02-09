module FucdRbac
  class MembershipsController < ::Railfrog::BaseController
    before_filter :verify_user_id_or_role_id_present
    
    def edit
      if params[:user_id]
        @user = User.find(params[:user_id])
        @roles = Role.find(:all)
      elsif params[:role_id]
        @role = Role.find(params[:role_id])
        @users = User.find(:all)
      end
    end
    
    def update
      respond_to do |format|
        begin # FIXME: find, create and destroy don't raise when they fail
          Membership.transaction do
            params[:memberships].each do |other_id, checked|
              user_id = params[:user_id] || other_id
              role_id = params[:role_id] || other_id
              
              if checked == '1'
                membership =  Membership.find_or_create_by_user_id_and_role_id(user_id, role_id)
#                raise if !membership && membership.new_record? # TODO: create a find_or_create_by_! method
              else
                membership = Membership.find_by_user_id_and_role_id(user_id, role_id)
#                raise unless membership
                membership.destroy if membership
              end
            end
          end
          flash[:notice] = 'Memberships were successfully updated.'
          
          format.html { redirect_to fucd_rbac_user_or_role_url }
          format.xml  { render :nothing => true }
        rescue
          #TODO: collect errors
          #TODO: add specs for this case
          format.html { edit; render :action => "edit" }
          format.xml  { render :xml => @errors.to_xml }
        end
      end
    end
    
    protected
    
      def verify_user_id_or_role_id_present
        unless params[:user_id] || params[:role_id]
          raise "You need to specify a user_id or role_id" #FIXME
        end
      end
      
      def fucd_rbac_user_or_role_url
        if params[:user_id]
          fucd_rbac_user_url(params[:user_id])
        elsif params[:role_id]
          fucd_rbac_role_url(params[:role_id])
        end
      end
  end
end
