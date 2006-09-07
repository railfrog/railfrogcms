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
  
  class Plugin
    attr_reader :database, :specification
    
    attr_reader :path_to_gem, :path_to_engine
    
    def initialize(specification_file)
      if File.exists? specification_file
        @specification = ::Gem::Specification.load(specification_file)
        @database = ::Plugin.find_or_create_by_name_and_version(specification.name, specification.version.to_s)
        @path_to_gem = File.expand_path(File.join(File.dirname(specification_file), '..', 'gems', specification.full_name))
        @path_to_engine = File.expand_path(File.join(RAILS_ROOT, 'vendor', 'plugins', "railfrog_#{name}"))
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
      elsif File.exist?(path_to_engine)
        raise Exceptions::PluginWithSameNameAlreadyEnabledException,
              "A plugin with the same name as the plugin you're trying to enable is already enabled."
      else
        FileUtils.mkdir(path_to_engine)
        Dir.chdir(@path_to_gem) do
          Dir["**/*"].each do |file_or_directory|
            dest = File.join(path_to_engine, file_or_directory)
            unless File.exist?(dest)
              if File.file?(file_or_directory)
                FileUtils.cp(file_or_directory, dest)                
              elsif File.directory?(file_or_directory)
                FileUtils.mkdir(dest)
              end
            end
          end
        end
        database.enabled = true
        database.save!
      end
    end
    
    def enabled?
      File.exist?(path_to_engine) && File.directory?(path_to_engine) && database.enabled?
    end
    
    def disable
      if disabled?
        raise Exceptions::PluginAlreadyDisabledException, 
              "Plugin #{name} (version: #{version}) is already disabled."
      else
        FileUtils.rm_rf(path_to_engine, :secure => true)
        database.enabled = false
        database.save!
      end
    end
    
    def disabled?
      not enabled?
    end
    
    def start
      if disabled?
        raise Exceptions::CannotStartDisabledPluginException,
              "Cannot start plugin #{name} (version: #{version}) because it's disabled. Only enabled plugins can be started."
      elsif started?
        raise Exceptions::PluginAlreadyStartedException,
              "Plugin #{name} (version: #{version}) is already started."
      else
        Engines.start "railfrog_#{name}"
      end
    end
    
    def started?
      Engines.active.any? { |engine| engine.name == "railfrog_#{name}" }
    end
    
    def stop
      if started?
        Engines.active.delete_if { |engine| engine.name == "railfrog_#{name}" }
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
