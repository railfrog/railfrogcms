require_dependency 'role_methods'

class RolePermission < ActiveRecord::Base
  belongs_to :permission
  belongs_to :role
  @@perm_cache = {}
  
  def name
    return self.permission.name
  end
  
  class <<self
    def update_perm_cache_parent(role_info)
      check_role = get_role(role_info)
      raise(RoleDoesntExistException, role_info) if check_role.nil?
      
      @@perm_cache[check_role.id] = {} if @@perm_cache[check_role.id].nil?
      @@perm_cache[check_role.id]['parent'] = check_role.parent_id
      return true
    end
  
    def clear_perm_cache(role_info, perm_info = nil)
      check_role = get_role(role_info)
      raise(RoleDoesntExistException, role_info) if check_role.nil?
      
      if perm_info.nil? or @@perm_cache[check_role.id].nil? then
        @@perm_cache[check_role.id] = nil
        return true
      end
      
      check_perm = get_perm(perm_info)
      raise(PermDoesntExistException, role_info) if check_perm.nil?
      
      @@perm_cache[check_role.id][check_perm.id] = nil
      return true
    end
  
    def set(role_info, perm_info, value = 0)
      params = check_role_and_perm(role_info, perm_info)
      check_role, check_perm = params
      
      if (newrp = find_by_role_id_and_permission_id(check_role.id, check_perm.id)).nil? then
        newrp = new
        newrp.role_id = check_role.id
        newrp.permission_id = check_perm.id
      end
      
      newrp.value = value == 1 ? 1 : 0
      newrp.save!
      clear_perm_cache(newrp.role_id, newrp.permission_id)
      
      return true
    end
    
    def remove_all(role_info)
      check_role = get_role(role_info)
      raise(RoleDoesntExistException, role_info) if check_role.nil?
      
      RolePermission.destroy_all ['role_id = ?', check_role.id.to_s]
    end
    
    def remove(role_info, perm_info)
      rp = get_rp_from_params(role_info, perm_info)
      rp.destroy
      
      return true
    end
    
    def check(role_info, perm_info, ignore_parents = false)
      role_info, perm_info = check_role_and_perm(role_info, perm_info)
      
      value = 0
      if @@perm_cache[role_info.id].nil? or @@perm_cache[role_info.id][perm_info.id].nil? then
        begin
          rp = get_rp_from_params(role_info, perm_info)
          @@perm_cache[rp.role_id] = {} if @@perm_cache[rp.role_id].nil?
          @@perm_cache[rp.role_id]['parent'] = role_info.parent_id if @@perm_cache[rp.role_id].empty?
          @@perm_cache[rp.role_id][rp.permission_id] = rp.value
        rescue RolePermDoesntExistException
        end
      end
      
      value = @@perm_cache[role_info.id][perm_info.id] unless @@perm_cache[role_info.id].nil? or @@perm_cache[role_info.id][perm_info.id].nil?
      value = check(role_info.parent_id, perm_info) unless role_info.parent_id == 0 or ignore_parents
      return value
    end
    
    def get_rp_from_params(role_info, perm_info)
      params = check_role_and_perm(role_info, perm_info)
      check_role, check_perm = params
      
      rp = find_by_role_id_and_permission_id(check_role.id, check_perm.id)
      raise(RolePermDoesntExistException, role_info) if rp.nil?
      return rp
    end
  end
end
