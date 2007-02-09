module FucdRbac
  class Role < ::ActiveRecord::Base
    set_table_name 'fucd_rbac_roles'
    
    has_many :memberships, :dependent => :destroy, :class_name => "FucdRbac::Membership"
    has_many :users, :through => :memberships, :class_name => "FucdRbac::User"
    has_many :permissions, :dependent => :destroy, :class_name => "FucdRbac::Permission"
    
    acts_as_tree #TODO: add specs for grants_permission_for?
    
    validates_presence_of :name, :message => 'is required'
    validates_uniqueness_of :name
    
    def has_user?(user)
      users.include? user
    end
    
    def grants_permission_for?(controller, action)
      ancestors.unshift(self).map(&:permissions).flatten.any? do |permission|
        permission.grants?(controller, action)
      end
    end
  end
end
