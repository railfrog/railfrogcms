module FucdRbac
  class Membership < ::ActiveRecord::Base
    set_table_name 'fucd_rbac_memberships'
    
    belongs_to :user, :class_name => "FucdRbac::User", :foreign_key => "user_id"
    belongs_to :role, :class_name => "FucdRbac::Role", :foreign_key => "role_id"
    
    validates_presence_of :user_id, :role_id, :message => 'is required'
  end
end
