class Object
  class Hash
    def method_missing(methid)
      meth = methid.to_s
      return self[meth] unless self[meth].nil?
      return self[meth.to_sym] unless self[meth.to_sym].nil?
      return nil
    end
    
    def create_errors_object
      self['errors'] = ActiveRecord::Errors.new(self)
      self
    end
    
    def errors
      method_missing('errors'.to_sym)
    end
  end
end