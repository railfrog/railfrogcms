module ActionView
  class Base
    private
      alias :plugin_system_original_full_template_path :full_template_path
      def full_template_path(template_path, extension)
        default_tmpl = plugin_system_original_full_template_path(template_path, extension)
        return default_tmpl if File.exist?(default_tmpl)
        
        @controller.additional_template_roots.each do |template_root|
          template = "#{template_root}/#{template_path}.#{extension}"
          return template if File.exist?(template)
        end
        
        default_tmpl
      end
  end
end
