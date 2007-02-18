module ActiveRecord
  class Errors
    def each_full_no_humanize
      each do |attr,msg|
        #if attr != 'base' then
         # yield(attr + ' ' + msg.to_s)
        #else
          yield(msg.to_s)
        #end
      end
    end
    
    def build_error(key, phrase, key_loc = 'system', phrase_loc = nil)
      phrase_loc = key_loc if phrase_loc.nil?
      return phrase._tkey(phrase_loc) / key._t(key_loc)
    end
  end
end