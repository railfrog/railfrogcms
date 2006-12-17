module FucdRbac
  class User < ::ActiveRecord::Base
    require 'digest/sha2'
    
    set_table_name 'fucd_rbac_users'
    
    has_many :memberships, :dependent => :destroy, :class_name => "FucdRbac::Membership"
    has_many :roles, :through => :memberships, :class_name => "FucdRbac::Role"
    has_many :logins, :dependent => :delete_all, :class_name => "FucdRbac::Login"
    
    validates_presence_of     :username, :first_name, :last_name,
                              :message => 'is required'
    validates_presence_of     :password, :message => 'is required', :on => :create
    validates_uniqueness_of   :username, :message => 'is already in use'
    validates_format_of       :email,
                              :with => %r{^([\w\+\-\.\#\$%&!?*\'=(){}|~_]+)@([0-9a-zA-Z\-\.\#\$%&!?*\'=(){}|~]+)+$},
                              :message => 'must be a valid email address'
    validates_length_of       :password, :minimum => 6,
                              :if => Proc.new { |user| user.new_password? }
    validates_confirmation_of :password, 
                              :if => Proc.new { |user| user.new_password? }
    
    attr_protected :salt
    
    before_save :create_salt_and_encrypt_password
    after_save  '@new_password = false'
    
    def full_name
      "#{first_name} #{last_name}"
    end
    
    def password=(value)
      unless value.blank?
        write_attribute(:password, value)
        @new_password = true
      end
    end
    
    def new_password?
      @new_password ||= false
    end
    
    def has_role?(role)
      roles.include? role
    end
    
    def has_permission_for?(controller, action)
      roles.any? { |role| role.grants_permission_for?(controller, action) }
    end
    
    def self.find_with_credentials(username, password)
      user = User.find(:first, :conditions => ["username = ?", username])
      if !user.nil? && user.password == User.encrypt_password(password, user.salt)
        return user
      end
      nil
    end
    
    def self.encrypt_password(password, salt)
      ::Digest::SHA256.hexdigest(password + salt)
    end
    
    protected
    
      def create_salt_and_encrypt_password
        if errors.count == 0 && new_password?
          self.salt = ::Digest::SHA256.hexdigest(Time.now.to_s)
          self.password = User.encrypt_password(self.password, self.salt)
        end
      end
  end
end
