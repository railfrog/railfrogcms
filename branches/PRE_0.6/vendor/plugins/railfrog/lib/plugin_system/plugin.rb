module PluginSystem
  class Plugin
    attr_reader :database, :specification
    
    attr_reader :path_to_gem
    
    def initialize(specification_file)
      if File.exists? specification_file
        @specification = ::Gem::Specification.load(specification_file)
        @database = ::Plugin.find_or_create_by_name_and_version(specification.name, specification.version.to_s)
        @path_to_gem = File.expand_path(File.join(File.dirname(specification_file), '..', 'gems', full_name))
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
      true
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
      true
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
        controller_path = File.join(path_to_gem, 'app', 'controllers')
        if config
          config.controller_paths << controller_path
        else
          ::ActionController::Routing.controller_paths << controller_path
        end
        load_paths = [].concat %w(
          app/models
          app/controllers
          app/helpers
          lib 
        ).map { |dir| "#{path_to_gem}/#{dir}" }.select { |dir| File.directory?(dir) }
        $LOAD_PATH.concat load_paths
        ::Dependencies.load_paths.concat load_paths
        @started = true
      end
      true
    end
    
    def started?
      @started
    end
    
    def stop
      if started?
        @started = false
        #TODO: Unload plugin
      end
      true
    end
    
    def uninstall
      if enabled?
        raise Exceptions::CannotUninstallEnabledPluginException,
              "Cannot uninstall plugin #{name} (version: #{version}) because it's enabled. Only disabled plugins can be uninstalled."
      else
        #FIXME: implement uninstall routine
        database.destroy
      end
      true
    end
    
    ##########################################    
    
    def name
      specification.name
    end
    
    def version
      specification.version.to_s
    end
    
    def full_name
      specification.full_name
    end
  end
end
