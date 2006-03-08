class AdminNavigationItem < ActiveRecord::Base
  def before_destroy
    Translation.destroy_all ['tr_key = ?', AdminNavigationItem.generate_unique_id(self.controller)]
  end
  
  def set(translation, lang = nil)
    return AdminNavigationItem.set(self.controller, translation, lang)
  end
  
  def translate(lang = nil)
    return AdminNavigationItem.translate(self.controller, lang)
  end
  
  class <<self
    def generate_unique_id(nav_id)
      return '--adminnav-' + nav_id.to_s
    end
    
    def enumerate(lang = nil)
      lang = Option.get('default_language') if lang.nil?
      
      items = find(:all)
      enumed = {}
      items.each { |item| enumed[item.translate] = item.controller }
      return enumed
    end
    
    def set(controller_name, translation, lang = nil)
      if (newnav = find_by_controller(controller_name)).nil? then
        newnav = self.new
        newnav.controller = controller_name
        newnav.save!
      end
      
      lang = Option.get('default_language') if lang.nil?
      Locale.swap(lang) { Locale.set_translation(generate_unique_id(newnav.controller), translation) }
      return true
    end
    
    def unset(controller_name)
      raise(AdminNavDoesntExistException) if (nav_info = find_by_controller(controller_name)).nil?
      nav_info.destroy
      return true
    end
    
    def translate(controller_name, lang = nil)
      lang = Option.get('default_language') if lang.nil?
      trans = nil
      
      raise(AdminNavDoesntExistException) if (nav_info = find_by_controller(controller_name)).nil?
      Locale.swap(lang) { trans = nav_info.controller._t('adminnav') }
      trans = controller_name if trans.nil?
      return trans
    end
  end
end
