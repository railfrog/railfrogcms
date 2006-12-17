class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table "fucd_rbac_logins", :force => true do |t|
      t.column "user_id",       :integer
      t.column "logged_in_at",  :datetime
      t.column "logged_out_at", :datetime
    end
    add_index "fucd_rbac_logins", ["user_id"], :name => "logins_user_id_index"
    
    create_table "fucd_rbac_memberships", :force => true do |t|
      t.column "user_id",    :integer
      t.column "role_id",    :integer
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end
    add_index "fucd_rbac_memberships", ["user_id"], :name => "memberships_user_id_index"
    add_index "fucd_rbac_memberships", ["role_id"], :name => "memberships_role_id_index"
    
    create_table "fucd_rbac_permissions", :force => true do |t|
      t.column "role_id",    :integer
      t.column "controller", :string
      t.column "action",     :string
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end
    add_index "fucd_rbac_permissions", ["role_id"], :name => "permissions_role_id_index"
    
    create_table "fucd_rbac_roles", :force => true do |t|
      t.column "parent_id",   :integer
      t.column "name",        :string
      t.column "description", :text
      t.column "created_at",  :datetime
      t.column "updated_at",  :datetime
    end
    add_index "fucd_rbac_roles", ["parent_id"], :name => "roles_parent_id_index"
    
    create_table "fucd_rbac_users", :force => true do |t|
      t.column "username",   :string
      t.column "first_name", :string
      t.column "last_name",  :string
      t.column "email",      :string
      t.column "password",   :string
      t.column "salt",       :string
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end
    
    admin_user = FucdRbac::User.create(:username => 'admin', :email => 'admin@localhost', :first_name => 'Administrator', :last_name => 'Railfrog', :password => 'ribbet!')
    admin_role = FucdRbac::Role.create(:name => 'Administrator')
    admin_role.permissions.create(:controller => '.*', :action => '.*')
    admin_role.users << admin_user
  end
  
  def self.down
    drop_table "fucd_rbac_logins"
    drop_table "fucd_rbac_memberships"
    drop_table "fucd_rbac_permissions"
    drop_table "fucd_rbac_roles"
    drop_table "fucd_rbac_users"
  end
end
