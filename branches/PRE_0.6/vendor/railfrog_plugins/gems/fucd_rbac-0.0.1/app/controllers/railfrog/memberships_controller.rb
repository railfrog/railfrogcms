class Railfrog::MembershipsController < Railfrog::BaseController
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
      begin
        Membership.transaction do
          params[:memberships].each do |other_id, checked|
            user_id = params[:user_id] || other_id
            role_id = params[:role_id] || other_id
            
            if checked == '1'
              Membership.find_or_create_by_user_id_and_role_id(user_id, role_id)
            else
              membership = Membership.find_by_user_id_and_role_id(user_id, role_id)
              membership.destroy if membership
            end
          end
        end
        flash[:notice] = 'Memberships were successfully updated.'
        
        format.html { redirect_to railfrog_users_url } #FIXME: change redirect_to url
        format.xml  { render :nothing => true }
      rescue
        format.html { edit; render :action => "edit" }
#        format.xml  { render :xml => errors.to_xml } #FIXME: collect errors?
      end
    end
  end
  
  protected
  
    def verify_user_id_or_role_id_present
      unless params[:user_id] || params[:role_id]
        raise "You need to specify a user_id or role_id" #FIXME
      end
    end
end