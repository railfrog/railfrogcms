class ExtensionAPI
  module DB
    def migrate_up(ext_name, file, classname); DB.migrate_up(ext_name, file, classname); end
    def migrate_down(ext_name, file, classname); DB.migrate_down(ext_name, file, classname); end
    
    class <<self
      def migrate_up(ext_name, file, classname)
        ExtensionAPI::Base.require_extension ext_name, file
        eval(classname + '.up')
      end
      
      def migrate_down(ext_name, file, classname)
        ExtensionAPI::Base.require_extension ext_name, file
        eval(classname + '.down')
      end
    end
  end
end