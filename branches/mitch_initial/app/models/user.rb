require_dependency 'role_methods'

class User < ActiveRecord::Base
  has_and_belongs_to_many :roles

  attr_reader :raw_password
  attr :password_confirmation
  
  validates_presence_of :login, :password
  validates_uniqueness_of :login
  validates_confirmation_of :password
  
  @@sess_hash = nil
  
  def password=(pass)
    return if pass.empty?
    write_attribute 'password', Auth::hash(pass)
    @raw_password = pass
  end
  
  def add_role(role_info)
    value = User.add_role(self, role_info)
    reload
    return value
  end
  
  def has_permission?(perm_info)
    return User.has_permission?(self, perm_info)
  end
  
  def remove_role(role_info)
    return User.remove_role(self, role_info)
  end
  
  class <<self
    def remove_role(user_info, role_info)
      check_user = get_user(user_info)
      raise(UserDoesntExistException, user_info) if check_user.nil?
      
      check_role = get_role(role_info)
      raise(RoleDoesntExistException, role_info) if check_role.nil?
      
      raise(UserDoesntHaveRoleException, role_info) if check_user.roles.detect { |role| role.name == check_role.name }.nil?
      
      check_user.roles.delete(check_role)
      check_user.save!
      return true
    end
  
    def has_permission?(user_info, perm_info)
      check_user = get_user(user_info)
      raise(UserDoesntExistException, user_info) if check_user.nil?
      
      check_perm = get_perm(perm_info)
      raise(PermDoesntExistException, perm_info) if check_perm.nil?  
      
      check_user.roles.each do |role|
        return true if role.has_permission?(check_perm)
      end
      
      return false
    end
  
    def add_role(user_info, role_info)
      check_user = get_user(user_info)
      raise(UserDoesntExistException, user_info) if check_user.nil?
      
      check_role = get_role(role_info)
      raise(RoleDoesntExistException, role_info) if check_role.nil?
      
      raise(UserAlreadyHasRoleException, role_info) unless check_user.roles.detect { |role| role.name == check_role.name }.nil?
      
      check_user.roles << check_role
      check_user.save!
      return true
    end
    
    def set_session(sess_hash)
      @@sess_hash = sess_hash
      Auth::session = sess_hash
      return true
    end
    
    def login(given_login, given_password)
      check = find_by_login(given_login)
      raise(UserDoesntExistException, given_login) if check.nil?
      
      hashed_password = Auth::hash(given_password)
      raise(InvalidPasswordException, given_password) unless check.password == hashed_password
      
      raise(NoSessionStoringHashException) if @@sess_hash.nil?
      raise(NoSessionStoringHashException) unless Auth::save(check.id, hashed_password)
      return true
    end
    
    def logout
      Auth::clear
      return true
    end
    
    def logged_in?(return_object = false)
      in_user, in_pass = Auth::load
      return false if in_user.nil? or in_pass.nil?
      check = find_by_id(in_user)
      return false if check.nil?
      return false unless Auth::second_hash(check.password) == in_pass
      return true unless return_object
      return check
    end
    
    def authenticate
      user_obj = logged_in?(true)
      return nil if user_obj === false
      return user_obj
    end
  end
end
