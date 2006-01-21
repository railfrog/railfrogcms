class Permission < ActiveRecord::Base
  def before_destroy
    Translation.destroy_all ['tr_key = ?', Permission.generate_unique_id(self.id)]
    RolePermission.destroy_all ['permission_id = ?', self.id.to_s]
  end
  
  def set(translation, lang = nil)
    return Permission.set(self.name, translation, lang)
  end
  
  def remove_translation(lang)
    return Permission.remove_translation(self.name, lang)
  end
  
  def translate(lang = nil)
    return Permission.translate(self.name, lang)
  end

  class <<self
    def generate_unique_id(perm_id)
      return '--permission-' + perm_id.to_s
    end
    
    def remove_translation(perm_name, lang = nil)
      raise(PermDoesntExistException) if (perm_info = find_by_name(perm_name)).nil?
      raise(PermOnlyHasOneTranslationException) if Translation.find_all_by_tr_key(generate_unique_id(perm_info.id)).length == 1
      raise(LangDoesntExistException) if (lang = Language.find_by_iso_639_2(lang)).nil?
      raise(PermDoesntExistException) if (trans = Translation.find_by_tr_key_and_language_id(generate_unique_id(perm_info.id), lang.id)).nil?
      trans.destroy
      return true
    end
  
    def set(perm_name, translation, lang = nil)
      if (newperm = find_by_name(perm_name)).nil? then
        newperm = new
        newperm.name = perm_name
        newperm.save!
      end
      
      lang = Option.get('default_language') if lang.nil?
      Locale.swap(lang) { Locale.set_translation(generate_unique_id(newperm.id), translation) }
      return true
    end
    
    def remove(perm_name)
      perm = find_by_name(perm_name)
      return E_PERM_EXISTS if perm.nil?
      perm.destroy
    end
    
    def translate(perm_name, lang = nil)
      lang = Option.get('default_language') if lang.nil?
      @trans = nil
      
      raise(PermissionDoesntExistException) if (perm_info = find_by_name(perm_name)).nil?
      Locale.swap(lang) { @trans = perm_info.id.to_s._t('permission') }
      @trans = perm_name if @trans.nil?
      return @trans
    end
  end
end
