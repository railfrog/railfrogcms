require_dependency 'role_methods'

class RoleExtension < ActiveRecord::Base
  belongs_to :extension
  belongs_to :role
  
  class <<self
    def set(role_info, extension_info, value = 0)
      check_role, check_ext = check_role_and_extension(role_info, extension_info)
      
    end
  end
end
