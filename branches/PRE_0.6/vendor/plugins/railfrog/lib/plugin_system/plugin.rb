module PluginSystem
  module Exceptions
    class PluginAlreadyEnabledException < Exception; end
    class PluginAlreadyDisabledException < Exception; end
    class PluginAlreadyStartedException < Exception; end
    class CannotStartDisabledPluginException < Exception; end
    class CannotUninstallEnabledPluginException < Exception; end
    class SpecificationFileDoesNotExistException < Exception; end
    class PluginWithSameNameAlreadyEnabledException < Exception; end
  end

  #TODO: disable plugins in database if removed from railsengines root  
  class Plugin
    attr_reader :database, :specification
    
    attr_reader :path_to_gem
    
    def initialize(specification_file)
      if File.exists? specification_file
        @specification = ::Gem::Specification.load(specification_file)
        @database = ::Plugin.find_or_create_by_name_and_version(specification.name, specification.version.to_s)
        @path_to_gem = File.expand_path(File.join(File.dirname(specification_file), '..', 'gems', specification.full_name))
      else
        raise Exceptions::SpecificationFileDoesNotExistException,
              "Specification file #{specification_file} does not exist."
      end
    end
    
    ##########################################
    
    def enable
      if enabled?
        raise Exceptions::PluginAlreadyEnabledException,
              "Plugin #{name} (version: #{version}) is already enabled."
      else
        database.enabled = true
        database.save!
      end
    end
    
    def enabled?
      database.enabled?
    end
    
    def disable
      if disabled?
        raise Exceptions::PluginAlreadyDisabledException, 
              "Plugin #{name} (version: #{version}) is already disabled."
      else
        database.enabled = false
        database.save!
      end
    end
    
    def disabled?
      not enabled?
    end
    
    def start(config=nil)
      if disabled?
        raise Exceptions::CannotStartDisabledPluginException,
              "Cannot start plugin #{name} (version: #{version}) because it's disabled. Only enabled plugins can be started."
      elsif started?
        raise Exceptions::PluginAlreadyStartedException,
              "Plugin #{name} (version: #{version}) is already started."
      else
        if config
          config.controller_paths << File.join(path_to_gem, 'app', 'controllers')
        else
          ::ActionController::Routing.controller_paths << File.join(path_to_gem, 'app', 'controllers')
        end
        (load_paths = Array.new).concat %w(
          app/models
          app/controllers
          app/helpers
          lib 
        ).map { |dir| "#{path_to_gem}/#{dir}" }.select { |dir| File.directory?(dir) }
        (autoload_paths = Array.new).concat %w(
          app/models
          app/controllers
          app/helpers
        ).map { |dir| "#{path_to_gem}/#{dir}" }.select { |dir| File.directory?(dir) }
        $LOAD_PATH.concat load_paths
        ::Dependencies.load_paths.concat autoload_paths
        @started = true
      end
    end
    
    def started?
      #Engines.active.any? { |engine| engine.name == "railfrog_#{name}" }
      @started
    end
    
    def stop
      if started?
        #TODO: Unload plugin
      end
    end
    
    def uninstall
      if enabled?
        raise Exceptions::CannotUninstallEnabledPluginException,
              "Cannot uninstall plugin #{name} (version: #{version}) because it's enabled. Only disabled plugins can be uninstalled."
      else
        #FIXME: implement uninstall routine
        database.destroy
      end
    end
    
    ##########################################    
    
    def name
      specification.name
    end
    
    def version
      specification.version.to_s
    end
  end
end
