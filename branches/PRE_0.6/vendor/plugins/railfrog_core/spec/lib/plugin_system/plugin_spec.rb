require File.dirname(__FILE__) + '/../../spec_helper'

#TODO:  Give instances of PluginSystem::Plugin better/more readable names? i.e. @helloworld_0_0_1 instead of @new_plugin
#TODO:  Make PluginSystem specs independent of Rails Engines
#TODO:  Migrate database when enabling plugin

context "A plugin (in general)" do
  setup do
    @new_plugin = PluginSystem::Plugin.new(
                    File.join(@@__plugin_system_specs, 'the_first_plugin-0.0.1.gemspec'))
  end
  
  specify "should be a PluginSystem::Plugin object" do
    @new_plugin.should_be_a_kind_of PluginSystem::Plugin
  end
  
  specify "should raise exception if specification file does not exist" do
    inexistent_spec = File.join(@@__plugin_system_specs, 'inexistent.gemspec')
    lambda { @inexistent_plugin = PluginSystem::Plugin.new(inexistent_spec) }.should_raise PluginSystem::Exceptions::SpecificationFileDoesNotExistException
    @inexistent_plugin.should_be nil
  end
  
  specify "should have a specification object" do
    @new_plugin.specification.should_be_kind_of Gem::Specification
  end
  
  specify "should be installed" do
    File.exists?(File.join(@@__plugin_system_specs, '..', 'gems', 'the_first_plugin-0.0.1')).should_be true
  end
  
  specify "should reflect changes made to the corresponding database entry immidately" do
    @new_plugin.database.should_not_be_enabled
    Plugin.find_by_name_and_version("the_first_plugin", "0.0.1").update_attribute(:enabled, true)
    @new_plugin.database.should_be_enabled
  end
end

context "A disabled plugin" do  
  setup do
    @disabled_plugin = PluginSystem::Plugin.new(
                         File.join(@@__plugin_system_specs, 'the_first_plugin-0.0.1.gemspec'))
    FileUtils.rm_rf(@disabled_plugin.path_to_engine, :secure => true)
  end
  
  specify "should be disabled" do
    @disabled_plugin.should_be_disabled
    File.exist?(@disabled_plugin.path_to_engine).should_be false
  end
  
  specify "cannot be disabled" do
    lambda { @disabled_plugin.disable }.should_raise PluginSystem::Exceptions::PluginAlreadyDisabledException
    @disabled_plugin.should_be_disabled
  end
  
  specify "should not be started" do
    @disabled_plugin.should_not_be_started
  end
  
  specify "cannot be started" do
    lambda { @disabled_plugin.start }.should_raise PluginSystem::Exceptions::CannotStartDisabledPluginException
    @disabled_plugin.should_not_be_started
  end
  
  specify "can be enabled" do
    lambda { @disabled_plugin.enable }.should_not_raise
    @disabled_plugin.should_be_enabled
    Dir.chdir(@disabled_plugin.path_to_gem) do
      Dir["**/*"].each do |file|
        a = File.join(@disabled_plugin.path_to_gem, file)
        b = File.join(@disabled_plugin.path_to_engine, file)
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
  
  teardown do
    FileUtils.rm_rf(@disabled_plugin.path_to_engine, :secure => true)
  end
end

context "An enabled plugin" do
  setup do
    @enabled_plugin = PluginSystem::Plugin.new(
                        File.join(@@__plugin_system_specs, 'the_first_plugin-0.0.1.gemspec'))
    @enabled_plugin.enable if @enabled_plugin.disabled?
  end
  
  specify "should be enabled" do
    @enabled_plugin.should_be_enabled
    Dir.chdir(@enabled_plugin.path_to_gem) do
      Dir["**/*"].each do |file|
        a = File.join(@enabled_plugin.path_to_gem, file)
        b = File.join(@enabled_plugin.path_to_engine, file)
        File.exist?(b).should_be true
        if File.file?(b)
          FileUtils.compare_file(a, b).should_be true
        end
      end
    end
  end
  
  specify "cannot be enabled" do
    lambda { @enabled_plugin.enable }.should_raise PluginSystem::Exceptions::PluginAlreadyEnabledException
    @enabled_plugin.should_be_enabled
  end
  
  specify "can be started" do
    lambda { @enabled_plugin.start }.should_not_raise
    @enabled_plugin.should_be_started
  end
  
  specify "can be disabled" do
    lambda { @enabled_plugin.disable }.should_not_raise
    @enabled_plugin.should_be_disabled
    File.exist?(@enabled_plugin.path_to_engine).should_be false
  end
  
  specify "cannot be uninstalled" do
    @enabled_plugin.should_be_enabled
    lambda { @enabled_plugin.uninstall }.should_raise PluginSystem::Exceptions::CannotUninstallEnabledPluginException
    #TODO: add code to check if plugin is really not uninstalled
  end
  
  teardown do
    @enabled_plugin.stop if @enabled_plugin.started?
    FileUtils.rm_rf(@enabled_plugin.path_to_engine, :secure => true)
  end
end

context "A started plugin" do
  setup do
    @started_plugin = PluginSystem::Plugin.new(
                        File.join(@@__plugin_system_specs, 'the_first_plugin-0.0.1.gemspec'))
    @started_plugin.enable if @started_plugin.disabled?
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
    lambda { @started_plugin.start }.should_raise PluginSystem::Exceptions::PluginAlreadyStartedException
    @started_plugin.should_be_started
  end
  
  teardown do
    @started_plugin.stop
    FileUtils.rm_rf(@started_plugin.path_to_engine, :secure => true)
  end
end

context "Two plugins with the same name" do
  setup do
    @another_plugin_001 = PluginSystem::Plugin.new(File.join(@@__plugin_system_specs, 'another_plugin-0.0.1.gemspec'))
    @another_plugin_002 = PluginSystem::Plugin.new(File.join(@@__plugin_system_specs, 'another_plugin-0.0.2.gemspec'))
    FileUtils.rm_rf(@another_plugin_001.path_to_engine, :secure => true)
  end
  
  specify "cannot both be enabled" do
    @another_plugin_001.enable
    lambda { @another_plugin_002.enable }.should_raise PluginSystem::Exceptions::PluginWithSameNameAlreadyEnabledException
    @another_plugin_001.should_be_enabled
    @another_plugin_002.should_not_be_enabled
  end
  
  teardown do
    FileUtils.rm_rf(@another_plugin_001.path_to_engine, :secure => true)
  end
end
