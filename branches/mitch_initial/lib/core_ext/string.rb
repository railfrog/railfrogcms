class Object
  class String
    def t?
      thekey = self
      trans = thekey.translate
      if trans == thekey then
        Translation.destroy_all ['tr_key = ? AND language_id = ?', thekey, Locale.language.id]
        return nil
      end
      
      return trans
    end
    
    def _t(type, translation = nil)
      trans_key = _tkey(type)
      trans = trans_key.translate
      if trans == trans_key then
        if translation.nil? then
          Locale.set_translation(trans_key, self)
          return self
        else
          Locale.set_translation(trans_key, translation)
          return translation
        end
      end
      
      return trans
    end
    
    def _tkey(type)
      return '--' + type + '-' + self
    end
  end
end