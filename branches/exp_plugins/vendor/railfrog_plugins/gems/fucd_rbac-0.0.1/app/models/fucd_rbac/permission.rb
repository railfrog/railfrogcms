module FucdRbac
  class Permission < ::ActiveRecord::Base
    set_table_name 'fucd_rbac_permissions'
    
    belongs_to :role, :class_name => "FucdRbac::Role", :foreign_key => "role_id"
    
    validates_presence_of :role_id, :message => 'is required'
    validates_presence_of :controller, :action
    
    # From http://blog.daveastels.com/articles/2006/08/29/role-based-authentication-from-rails-recipes-part-2
    def grants?(controller_name, action_name)
      get_controller_regexp.match(controller_name) && get_action_regexp.match(action_name)
    end
    
    def get_action_regexp
      @action_regexp || (@action_regexp = Regexp.new(action))
    end
    
    def get_controller_regexp
      @controller_regexp || (@controller_regexp = Regexp.new(controller))
    end
  end
end