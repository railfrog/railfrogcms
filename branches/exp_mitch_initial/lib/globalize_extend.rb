module Globalize
  class Locale
    @@old_locale = ''
    
    def self.swap(newrtf = nil)
      return set(@@old_locale) if newrtf.nil?
      
      if block_given? then
        swap(newrtf)
        yield
        swap
        return
      end
      
      @@old_locale = @@active.code
      return set(newrtf)
    end
  end
end