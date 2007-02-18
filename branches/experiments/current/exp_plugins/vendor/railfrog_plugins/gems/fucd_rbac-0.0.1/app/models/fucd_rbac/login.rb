module FucdRbac
  class Login < ::ActiveRecord::Base
    set_table_name 'fucd_rbac_logins'
    
    belongs_to :user, :class_name => "FucdRbac::User", :foreign_key => "user_id"
    
    before_create :set_login_time
    before_destroy :set_logout_time
    
    attr_accessor :username, :password
    attr_protected :user
    
    def validate
      unless user.kind_of? User
        errors.add_to_base('Invalid username or password!')
      end
    end
    
    def set_login_time
      self.logged_in_at = Time.now
    end
    
    def set_logout_time
      self.logged_out_at = Time.now
    end
    
    def initialize(attributes=nil)
      super
      if self.username && self.password
        self.user = User.find_with_credentials(self.username, self.password)
      end
    end
    
    def destroy
      save unless new_record?
      freeze
    end
    # Creating a custom destroy method breakes the method chain for ARs
    # callbacks 'before_destroy' and 'after_destroy'. This line makes those
    # methods available again:
    alias_method_chain :destroy, :callbacks 
  end
end
