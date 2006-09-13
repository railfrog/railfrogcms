# This file is heavily based on code from Rails Engines by James Adam

module ::ActionView
  class Base
    private
      def full_template_path(template_path, extension)
        # If the template exists in the normal application directory,
        # return that path
        default_template = "#{@base_path}/#{template_path}.#{extension}"
        return default_template if File.exist?(default_template)
        
        # Otherwise, check in the directories of the started plugins to see if
        # the template can be found there. Load this in order so that more 
        # recently started Plugins will take priority.
        @started_plugins = ::PluginSystem::Base.plugin_system.plugins.values.select { |plugin| plugin.started? }
        ::PluginSystem::DependencyList.from_plugin_list(@started_plugins).dependency_order.each do |spec|
          plugin_root = ::PluginSystem::Base.plugin_system.plugins(spec.name, spec.version.to_s).path_to_gem
          site_specific_path = File.join(plugin_root, 'app', 'views',  
                                         template_path.to_s + '.' + extension.to_s)
          return site_specific_path if File.exist?(site_specific_path)
        end
        
        # If it cannot be found anywhere, return the default path, where the
        # user *should* have put it.  
        return "#{@base_path}/#{template_path}.#{extension}" 
      end
  end
end
