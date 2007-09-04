class ExtensionAPI
  module Controller
    @@methods = nil
    
    class <<self
      def set_methods(method_list)
        return false unless method_list.kind_of?(Hash)
        @@methods = {}
        method_list.each do |key,meth|
          next unless key.kind_of?(String) or key.kind_of?(Symbol)
          next unless meth.kind_of?(Method)
          @@methods[key.to_sym] = meth
        end
        
        if @@methods.length == 0 then
          @@methods = nil
          return false
        end
        
        return true
      end
      
      def add_method(key, method)
        method_list = @@methods.nil? ? {} : @@methods
        method_list[key] = method
        return set_methods(method_list)
      end
      
      def call_method(method_id, *args)
        method_missing(method_id.to_sym, *args)
      end
     
      def method_missing(method_id, *args)
        unless @@methods.nil? then
          begin
            method_id = method_id.to_s[5..(method_id.to_s.length - 1)].to_sym if method_id.to_s[0..4] == 'call_'
            meth = @@methods[method_id]
            return meth.call(*args) unless args.empty?
            return meth.call
          rescue NameError
            return super(method_id, *args)
          end
        end
        
        super(method_id, *args)
      end
    end
  end
end