require File.dirname(__FILE__) + '/../../spec_helper'

PluginSystem::Base.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "data"))

#TODO:  Give instances of PluginSystem::Plugin better/more readable names? i.e. @helloworld_0_0_1 instead of @new_plugin
#TODO:  Make PluginSystem specs independent of Rails Engines
#TODO:  Migrate database when enabling plugin

context "A plugin (in general)" do
  setup do
    the_first_plugin_spec = File.join(PluginSystem::Base.path_to_specs, "the_first_plugin-0.0.1.gemspec")
    @new_plugin = PluginSystem::Plugin.new(the_first_plugin_spec)
  end
  
  specify "should be a PluginSystem::Plugin object" do
    @new_plugin.should_be_a_kind_of PluginSystem::Plugin
  end
  
  specify "should raise exception if specification file does not exist" do
    inexistent_spec = File.join(PluginSystem::Base.path_to_specs, "inexistent.gemspec")
    lambda { @inexistent_plugin = PluginSystem::Plugin.new(inexistent_spec) }.should_raise PluginSystem::SpecificationFileDoesNotExistException
    @inexistent_plugin.should_be nil
  end
  
  specify "should have a specification object" do
    @new_plugin.specification.should_be_kind_of Gem::Specification
  end
  
  specify "should be installed" do
    PluginSystem::Base.installed_plugins.should_include ["the_first_plugin", "0.0.1"]
  end
end

context "A disabled plugin" do  
  setup do
    the_first_plugin_spec = File.join(PluginSystem::Base.path_to_specs, "the_first_plugin-0.0.1.gemspec")
    @disabled_plugin = PluginSystem::Plugin.new(the_first_plugin_spec)
    FileUtils.rm_rf(File.join(Engines.config(:root), "railfrog_the_first_plugin"), :secure => true) if File.exist?(File.join(Engines.config(:root), "railfrog_the_first_plugin"))
  end
  
  specify "should be disabled" do
    @disabled_plugin.should_be_disabled
    File.exist?(@disabled_plugin.path_to_the_plugin_in_the_railsengines_plugins_directory).should_be false
  end
  
  specify "cannot be disabled" do
    lambda { @disabled_plugin.disable }.should_raise PluginSystem::PluginIsAlreadyDisabledException
    @disabled_plugin.should_be_disabled
  end
  
  specify "should not be started" do
    @disabled_plugin.should_not_be_started
  end
  
  specify "cannot be started" do
    lambda { @disabled_plugin.start }.should_raise PluginSystem::CannotStartDisabledPluginException
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
    violated
  end
  
  def teardown
    FileUtils.rm_rf(File.join(Engines.config(:root), "railfrog_the_first_plugin"), :secure => true)
  end
end

context "An enabled plugin" do
  setup do
    the_first_plugin_spec = File.join(PluginSystem::Base.path_to_specs, "the_first_plugin-0.0.1.gemspec")
    @enabled_plugin = PluginSystem::Plugin.new(the_first_plugin_spec)
    @enabled_plugin.enable
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
    lambda { @enabled_plugin.enable }.should_raise PluginSystem::PluginIsAlreadyEnabledException
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
    lambda { @enabled_plugin.uninstall }.should_raise PluginSystem::CannotUninstallEnabledPluginException
    #TODO: add code to check if plugin is really not uninstalled
  end
  
  def teardown
    FileUtils.rm_rf(File.join(Engines.config(:root), "railfrog_the_first_plugin"), :secure => true)
  end
end

context "A started plugin" do  
  setup do
    the_first_plugin_spec = File.join(PluginSystem::Base.path_to_specs, "the_first_plugin-0.0.1.gemspec")
    @started_plugin = PluginSystem::Plugin.new(the_first_plugin_spec)
    @started_plugin.enable
    @started_plugin.start
  end
  
  specify "should be enabled" do
    @started_plugin.should_be_enabled
  end
  
  specify "should be started" do
    @started_plugin.should_be_started
    #TODO: Make this independent of Rails Engines (i.e. specs like "controllers should be accessible")
    Engines[:railfrog_the_first_plugin].should_be_an_instance_of Engine
  end
  
  specify "cannot be started" do
    lambda { @started_plugin.start }.should_raise PluginSystem::PluginIsAlreadyStartedException
    @started_plugin.should_be_started
  end
  
  def teardown
    FileUtils.rm_rf(File.join(Engines.config(:root), "railfrog_the_first_plugin"), :secure => true)
  end
end
