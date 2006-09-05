module RailFrog
  module PluginSystem  
    class PluginIsAlreadyEnabledException < RailFrog::Exception; end
    class PluginIsAlreadyDisabledException < RailFrog::Exception; end
    class PluginIsAlreadyStartedException < RailFrog::Exception; end
    class CannotStartDisabledPluginException < RailFrog::Exception; end
    class CannotUninstallEnabledPluginException < RailFrog::Exception; end
    class SpecificationFileDoesNotExistException < RailFrog::Exception; end
    
    class Plugin
      attr_reader :database, :specification
      
      def initialize(specification_file)
        if File.exists? specification_file
          @specification = Gem::Specification.load(specification_file)
          @started = false
          @database = ::Plugin.find_or_create_by_name_and_version(specification.name, specification.version.to_s)
        else
          raise SpecificationFileDoesNotExistException, "Specification file #{specification_file} does not exist."
        end
      end
      
      def enable
        if self.enabled?
          raise PluginIsAlreadyEnabledException
        else
          unless File.exist?(path_to_the_plugin_in_the_railsengines_plugins_directory)
            FileUtils.mkdir(path_to_the_plugin_in_the_railsengines_plugins_directory)
          end
          Dir.chdir(path_to_the_plugin_in_the_railfrog_plugins_directory) do
            Dir["**/*"].each do |file_or_directory|
              dest = File.join(
                path_to_the_plugin_in_the_railsengines_plugins_directory,
                file_or_directory)
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
      
      #TODO: Do we need a "enabled" column in the db or do we want to detect 
      #whether a plugin is enabled or not by trying to find it in the 
      #railsengines root?
      def enabled?
        database.enabled?
      end

      def disable
        if self.disabled?
          raise PluginIsAlreadyDisabledException
        else
          FileUtils.rm_rf(
            path_to_the_plugin_in_the_railsengines_plugins_directory,
            :secure => true)
          database.enabled = false
          database.save!
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
          Engines.start "railfrog_#{specification.name}"
          @started = true
        end
      end
      
      def started?
        @started
      end
      
      def uninstall
        if self.enabled?
          raise CannotUninstallEnabledPluginException
        else
          database.destroy
        end
      end
      
      def path_to_the_plugin_in_the_railfrog_plugins_directory
        File.expand_path(
          File.join(RailFrog::PluginSystem::Base.root, specification.full_name))
      end
      
      def path_to_the_plugin_in_the_railsengines_plugins_directory
        File.expand_path(
          File.join(Engines.config(:root), "railfrog_#{specification.name}"))
      end
    end
  end
end
