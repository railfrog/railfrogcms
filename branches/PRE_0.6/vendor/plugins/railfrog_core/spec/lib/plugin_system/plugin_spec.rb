require File.dirname(__FILE__) + '/../../spec_helper'

RailFrog::PluginSystem::Base.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "data", "gems"))

#TODO: give instances of RailFrog::PluginSystem::Plugin better/more readable names? i.e. @helloworld_0_0_1 instead of @new_plugin
#FIXME: remove 'railfrog_hello_world' directory as soon as it's not needed anymore
#       FileUtils.rm_rf(File.join(Engines.config(:root), "railfrog_hello_world"), :secure => true)

context "A plugin (in general)" do
  setup do
    helloworld_spec = File.join(RailFrog::PluginSystem::Base.root, "..", "specifications", "hello_world-0.0.1.gemspec")
    @new_plugin = RailFrog::PluginSystem::Plugin.new(helloworld_spec)
  end
  
  specify "should be a RailFrog::PluginSystem::Plugin object" do
    @new_plugin.should_be_a_kind_of RailFrog::PluginSystem::Plugin
  end
  
  specify "should raise exception if specification file does not exist" do
    inexistent_spec = File.join(RailFrog::PluginSystem::Base.root, "..", "specifications", "inexistent.gemspec")
    lambda { @inexistent_plugin = RailFrog::PluginSystem::Plugin.new(inexistent_spec) }.should_raise RailFrog::PluginSystem::SpecificationFileDoesNotExistException
    @inexistent_plugin.should_be nil
  end
  
  specify "should have a specification object" do
    @new_plugin.specification.should_be_kind_of Gem::Specification
  end
  
  specify "should be registered" do
    @new_plugin.database.should_be_kind_of Plugin
  end
  
  specify "should be installed" do
    RailFrog::PluginSystem::Base.installed_plugins.should_include [@new_plugin.name, @new_plugin.version]
  end
  
  specify "should be disabled" do
    @new_plugin.should_be_disabled
  end
  
  specify "enabled? should redirect the call to database.enabled?" do
    violated
  end
  
  def teardown
    Plugin.destroy_all
  end
end

context "A disabled plugin" do  
  setup do
    helloworld_spec = File.join(RailFrog::PluginSystem::Base.root, "..", "specifications", "hello_world-0.0.1.gemspec")
    @disabled_plugin = RailFrog::PluginSystem::Plugin.new(helloworld_spec)
    FileUtils.rm_rf(File.join(Engines.config(:root), "railfrog_hello_world"), :secure => true) if File.exist?(File.join(Engines.config(:root), "railfrog_hello_world"))
  end
  
  specify "should be disabled" do
    @disabled_plugin.should_be_disabled
    File.exist?(@disabled_plugin.path_to_the_plugin_in_the_railsengines_plugins_directory).should_be false
  end
  
  specify "cannot be disabled" do
    lambda { @disabled_plugin.disable }.should_raise RailFrog::PluginSystem::PluginIsAlreadyDisabledException
    @disabled_plugin.should_be_disabled
  end
  
  specify "should not be started" do
    @disabled_plugin.should_not_be_started
  end
  
  specify "cannot be started" do
    lambda { @disabled_plugin.start }.should_raise RailFrog::PluginSystem::CannotStartDisabledPluginException
    @disabled_plugin.should_not_be_started
  end
  
  specify "can be enabled" do
    lambda { @disabled_plugin.enable }.should_not_raise
    @disabled_plugin.should_be_enabled
    File.exist?(@disabled_plugin.path_to_the_plugin_in_the_railfrog_plugins_directory).should_be true
    File.directory?(@disabled_plugin.path_to_the_plugin_in_the_railfrog_plugins_directory).should_be true
    Dir.chdir(@disabled_plugin.path_to_the_plugin_in_the_railfrog_plugins_directory) do
      Dir["**/*"].each do |file|
        a = File.join(@disabled_plugin.path_to_the_plugin_in_the_railfrog_plugins_directory, file)
        b = File.join(@disabled_plugin.path_to_the_plugin_in_the_railsengines_plugins_directory, file)
        File.exist?(b).should_be true
        if File.file?(b)
          FileUtils.compare_file(a, b).should_be true
        end
      end
    end
  end
  
  specify "can be uninstalled" do
    lambda { @disabled_plugin.uninstall }.should_not_raise
    @disabled_plugin.database.should_be nil
    File.exist?(@disabled_plugin.path_to_the_plugin_in_the_railsengines_plugins_directory).should_be false
    File.exist?(@disabled_plugin.path_to_the_plugin_in_the_railfrog_plugins_directory).should_be false
  end
end

context "An enabled plugin" do
  setup do
    helloworld_spec = File.join(RailFrog::PluginSystem::Base.root, "..", "specifications", "hello_world-0.0.1.gemspec")
    @enabled_plugin = RailFrog::PluginSystem::Plugin.new(helloworld_spec)
    #Is it ok to use .enable here?
    FileUtils.rm_rf(File.join(Engines.config(:root), "railfrog_hello_world"), :secure => true) if File.exist?(File.join(Engines.config(:root), "railfrog_hello_world"))
    @enabled_plugin.enable unless @enabled_plugin.enabled?
  end
  
  specify "should be enabled" do
    @enabled_plugin.should_be_enabled
    File.exist?(@enabled_plugin.path_to_the_plugin_in_the_railfrog_plugins_directory).should_be true
    File.directory?(@enabled_plugin.path_to_the_plugin_in_the_railfrog_plugins_directory).should_be true
    Dir.chdir(@enabled_plugin.path_to_the_plugin_in_the_railfrog_plugins_directory) do
      Dir["**/*"].each do |file|
        a = File.join(@enabled_plugin.path_to_the_plugin_in_the_railfrog_plugins_directory, file)
        b = File.join(@enabled_plugin.path_to_the_plugin_in_the_railsengines_plugins_directory, file)
        File.exist?(b).should_be true
        if File.file?(b)
          FileUtils.compare_file(a, b).should_be true
        end
      end
    end
  end
  
  specify "cannot be enabled" do
    lambda { @enabled_plugin.enable }.should_raise RailFrog::PluginSystem::PluginIsAlreadyEnabledException
    @enabled_plugin.should_be_enabled
  end
  
  specify "can be started" do
    lambda { @enabled_plugin.start }.should_not_raise
    @enabled_plugin.should_be_started
  end
  
  specify "can be disabled" do
    lambda { @enabled_plugin.disable }.should_not_raise
    @enabled_plugin.should_be_disabled
    File.exist?(@enabled_plugin.path_to_the_plugin_in_the_railsengines_plugins_directory).should_be false
  end
  
  specify "cannot be uninstalled" do
    @enabled_plugin.should_be_enabled
    lambda { @enabled_plugin.uninstall }.should_raise RailFrog::PluginSystem::CannotUninstallEnabledPluginException
    File.exist?(@enabled_plugin.path_to_the_plugin_in_the_railsengines_plugins_directory).should_be true
    File.exist?(@enabled_plugin.path_to_the_plugin_in_the_railfrog_plugins_directory).should_be true
    @enabled_plugin.database.should_not_be nil
  end
end

context "A started plugin" do  
  setup do
    helloworld_spec = File.join(RailFrog::PluginSystem::Base.root, "..", "specifications", "hello_world-0.0.1.gemspec")
    @started_plugin = RailFrog::PluginSystem::Plugin.new(helloworld_spec)
    #Is it ok to use .enable here?
    @started_plugin.enable if @started_plugin.disabled?
    @started_plugin.start
  end
  
  specify "should be enabled" do
    @started_plugin.should_be_enabled
  end
  
  specify "should be started" do
    @started_plugin.should_be_started
  end
  
  specify "cannot be started" do
    lambda { @started_plugin.start }.should_raise RailFrog::PluginSystem::PluginIsAlreadyStartedException
    @started_plugin.should_be_started
  end
  
  specify "should have more specifications" do
    violated "not enough specs"
  end
end
