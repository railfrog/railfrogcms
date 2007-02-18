class ExtensionAPI
  class Base
    def require_extension(ext_name, file)
      Base.require_extension(ext_name, file)
    end
    
    class <<self
      def require_extension(ext_name, file)
        require_dependency Extension.path + '/' + ext_name + '/' + file + '.rb'
      end
    end
  end
end