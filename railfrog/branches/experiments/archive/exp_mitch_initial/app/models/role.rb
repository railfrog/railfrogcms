require_dependency 'role_methods'

class Role < ActiveRecord::Base
  has_many :role_permissions, :include => [:permission, :role]

  def before_destroy
    Translation.destroy_all ['tr_key = ?', generate_unique_id]
    RolePermission.remove_all self
  end
  
  def generate_unique_id
    return Role.generate_unique_id(self.name)
  end
  
  def parent
    return Role.find_by_id(self.parent_id)
  end
  
  def translate(lang = nil)
    return Role.translate(self.name, lang)
  end
  
  def set(translation, lang = nil)
    return Role.set(self.name, translation, lang)
  end
  
  def set_permission(perm_info, value = 0)
    retval = Role.set_permission(self, perm_info, value)
    reload
    return retval
  end
  
  def has_permission?(perm_info, ignore_parents = false)
    return Role.has_permission?(self, perm_info, ignore_parents)
  end
  
  def set_parent(parent_role)
    value = Role.set_parent(self, parent_role)
    reload
    return value
  end
  
  def remove_parent
    value = Role.remove_parent(self)
    reload
    return value
  end
  
  def set_default
    return Role.set_default(self)
  end

  def remove_translation(lang)
    return Role.remove_translation(self.name, lang)
  end

  class <<self
    def remove_translation(role_name, lang = nil)
      raise(RoleDoesntExistException) if (role_info = find_by_name(role_name)).nil?
      raise(RoleOnlyHasOneTranslationException) if Translation.find_all_by_tr_key(generate_unique_id(role_info.id)).length == 1
      raise(LangDoesntExistException) if (lang = Language.find_by_iso_639_2(lang)).nil?
      raise(RoleDoesntExistException) if (trans = Translation.find_by_tr_key_and_language_id(generate_unique_id(role_info.id), lang.id)).nil?
      trans.destroy
      return true
    end
    
    def remove_parent(child_role)
      check_role = get_role(child_role)
      raise(RoleDoesntExistException, child_role) if check_role.nil?
      
      check_role.parent_id = 0
      check_role.save!
      
      RolePermission.update_perm_cache_parent(check_role)
      return true
    end
  
    def set_parent(child_role, parent_role)
      check_role = get_role(parent_role)
      raise(RoleDoesntExistException, parent_role) if check_role.nil?
      check_child = get_role(child_role)
      raise(RoleDoesntExistException, child_role) if check_child.nil?
      
      check_child.parent_id = check_role.id
      check_child.save!
      
      RolePermission.update_perm_cache_parent(check_child)
      return true
    end
      
    def generate_unique_id(role_id)
      return '--role-' + role_id.to_s
    end
    
    def set_permission(role_info, perm_info, value = 0)
      RolePermission.set(role_info, perm_info, value)
    end
    
    def has_permission?(role_info, perm_info, ignore_parents = false)
      begin
        return RolePermission.check(role_info, perm_info, ignore_parents) == 1
      rescue RoleDoesntExistException
        return false
      rescue PermDoesntExistException
        return false
      rescue RolePermDoesntExistException
        return false
      end
    end

    def set(role_name, translation, lang = nil)
      if (newrole = find_by_name(role_name)).nil? then
        newrole = new
        newrole.name = role_name
        newrole.save!
      end
      
      lang = Option.get('default_language') if lang.nil?
      Locale.swap(lang) { Locale.set_translation(generate_unique_id(newrole.id), translation) }
      return true
    end
    
    def remove(role_name)
      check = find_by_name(role_name)
      raise(RoleDoesntExistException, role_name) if check.nil?
      check.destroy
      return true
    end
    
    def translate(role_name, lang = nil)
      lang = Option.get('default_language') if lang.nil?
      trans = nil
      
      raise(RoleDoesntExistException) if (role_info = find_by_name(role_name)).nil?
      Locale.swap(lang) { trans = role_info.id.to_s._t('role') }
      trans = role_name if trans.nil?
      return trans
    end
    
    def set_default(role_name)
      role_info = get_role(role_name)
      raise(RoleDoesntExistException, role_name) if role_info.nil?
      self.update_all 'is_default = 0'
      role_info.is_default = 1
      role_info.save!
      true
    end
    
    def default
      find_by_is_default(1)
    end
  end
end
