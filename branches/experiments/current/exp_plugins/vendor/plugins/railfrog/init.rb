silence_warnings { require 'rails/version' } # it may already be loaded
unless Rails::VERSION::MAJOR >= 1 && Rails::VERSION::MINOR >= 2
  puts <<-end_of_warning
Railfrog requires Rails 1.2 or later!
  end_of_warning
else
  require 'hash_extension' #...
  require 'plugin_system'  #...
  
  PluginSystem::Instance = PluginSystem::Base.new(File.join(RAILS_ROOT, 'vendor', 'railfrog_plugins')) #...
  
  require 'plugin_system/rails_ext' #...
  
  # FIXME: REMOVE THIS
  if RAILS_ENV == 'test'
    PluginSystem::Instance.installed_plugins.each do |plugin|
      plugin.enable if plugin.disabled?
    end
  end
  ###################
  
  PluginSystem::Instance.start(config) # Start the plug-in system
end
