module RailFrog
  module PluginSystem  
    class PluginIsAlreadyEnabledException < RailFrog::Exception; end
    class PluginIsAlreadyDisabledException < RailFrog::Exception; end
    class PluginIsAlreadyStartedException < RailFrog::Exception; end
    class CannotStartDisabledPluginException < RailFrog::Exception; end
    class CannotUninstallEnabledPluginException < RailFrog::Exception; end
    class SpecificationFileDoesNotExistException < RailFrog::Exception; end
    class FailedToEnablePluginException < RailFrog::Exception; end
    class FailedToDisablePluginException < RailFrog::Exception; end
    class FailedToStartPluginException < RailFrog::Exception; end
    
    class Plugin      
      attr_reader :database, :specification
      
      def initialize(specification_file)
        if File.exists? specification_file
          @specification = Gem::Specification.load(specification_file)
          @database = ::Plugin.find_or_create_by_name_and_version(specification.name, specification.version.to_s)
          @started = false
        else
          raise SpecificationFileDoesNotExistException 
        end
      end
      
      def enable
        if self.enabled?
          raise PluginIsAlreadyEnabledException
        else
          begin
            source = File.join(path_to_the_plugin_in_the_railfrog_plugins_directory, ".")
            dest = path_to_the_plugin_in_the_railsengines_plugins_directory
            FileUtils.cp_r source, dest
            @database.enabled = true
            @database.save!
          rescue
            raise FailedToEnablePluginException
          end
        end
      end
      
      #TODO: Do we need a "enabled" column in the db or do we want to detect 
      #whether a plugin is enabled or not by trying to find it in the 
      #railsengines root?
      def enabled?
        @database.enabled?
      end

      def disable
        if self.disabled?
          raise PluginIsAlreadyDisabledException
        else
          begin
            FileUtils.rm_rf path_to_the_plugin_in_the_railsengines_plugins_directory
            @database.enabled = false
            @database.save!
          rescue
            raise FailedToDisablePluginException
          end
        end
      end
      
      def disabled?
        not enabled?
      end
      
      def start
        if self.disabled?
          raise CannotStartDisabledPluginException
        elsif self.started?
          raise PluginIsAlreadyStartedException
        else
          begin
            Engines.start "railfrog_#{specification.name}"
            @started = true
          rescue
            raise FailedToStartPluginException
          end
        end
      end
      
      def started?
        @started
      end
      
      def uninstall
        if self.enabled?
          raise CannotUninstallEnabledPluginException
        else
          @database.destroy
          @database = nil
        end
      end
      
      def path_to_the_plugin_in_the_railfrog_plugins_directory
        File.expand_path(File.join(RailFrog::PluginSystem::Base.root, specification.full_name))
      end
      
      def path_to_the_plugin_in_the_railsengines_plugins_directory
        File.expand_path(File.join(Engines.config(:root), "railfrog_#{specification.name}"))
      end
    end
  end
end