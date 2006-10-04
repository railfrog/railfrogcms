require File.dirname(__FILE__) + '/../../spec_helper'

#TODO:  Give instances of PluginSystem::Plugin better/more readable names? i.e. @helloworld_0_0_1 instead of @new_plugin
#TODO:  Migrate database when enabling plugin

module PluginSystem
  context "A plugin (in general)" do
    setup do
      @new_plugin = Plugin.new(
                      File.join(@@__plugin_system_specs, 'the_first_plugin-0.0.1.gemspec'))
    end
    
    specify "should raise exception if specification file does not exist" do
      inexistent_spec = File.join(@@__plugin_system_specs, 'inexistent.gemspec')
      lambda { @inexistent_plugin = Plugin.new(inexistent_spec) }.should_raise Exceptions::SpecificationFileDoesNotExistException
      @inexistent_plugin.should_be nil
    end
    
    specify "should have a specification object" do
      @new_plugin.specification.should_be_kind_of ::Gem::Specification
    end
    
    specify "should be installed" do
      File.exist?(File.join(@@__plugin_system_specs, '..', 'gems', 'the_first_plugin-0.0.1'))
    end
  end
  
  context "A disabled plugin" do
    setup do
      @disabled_plugin = Plugin.new(
                           File.join(@@__plugin_system_specs, 'the_first_plugin-0.0.1.gemspec'))
      @disabled_plugin.disable unless @disabled_plugin.disabled? # replace by mock/stub
    end
    
    specify "should be disabled" do
      @disabled_plugin.should_be_disabled
    end
    
    specify "cannot be disabled" do
      lambda { @disabled_plugin.disable }.should_raise Exceptions::PluginAlreadyDisabledException
      @disabled_plugin.should_be_disabled
    end
    
    specify "should not be started" do
      @disabled_plugin.should_not_be_started
    end
    
    specify "cannot be started" do
      lambda { @disabled_plugin.start }.should_raise Exceptions::CannotStartDisabledPluginException
      @disabled_plugin.should_not_be_started
    end
    
    specify "can be enabled" do
      lambda { @disabled_plugin.enable }.should_not_raise
      @disabled_plugin.should_be_enabled
    end
    
    specify "can be uninstalled" do
      violated
    end
  end
  
  context "An enabled plugin" do
    setup do
      @enabled_plugin = Plugin.new(
                          File.join(@@__plugin_system_specs, 'the_first_plugin-0.0.1.gemspec'))
      @enabled_plugin.enable unless @enabled_plugin.enabled? # replace by mock/stub
    end
    
    specify "should be enabled" do
      @enabled_plugin.should_be_enabled
    end
    
    specify "cannot be enabled" do
      lambda { @enabled_plugin.enable }.should_raise Exceptions::PluginAlreadyEnabledException
      @enabled_plugin.should_be_enabled
    end
    
    specify "can be started" do
      lambda { @enabled_plugin.start }.should_not_raise
      @enabled_plugin.should_be_started
    end
    
    specify "can be disabled" do
      lambda { @enabled_plugin.disable }.should_not_raise
      @enabled_plugin.should_be_disabled
    end
    
    specify "cannot be uninstalled" do
      @enabled_plugin.should_be_enabled
      lambda { @enabled_plugin.uninstall }.should_raise Exceptions::CannotUninstallEnabledPluginException
      #TODO: add code to check if plugin is really not uninstalled
    end
    
    teardown do
      @enabled_plugin.stop if @enabled_plugin.started?
    end
  end
  
  context "A started plugin" do
    setup do
      @started_plugin = Plugin.new(
                          File.join(@@__plugin_system_specs, 'the_first_plugin-0.0.1.gemspec'))
      @started_plugin.database.stubs(:enabled?).returns(true)
      @started_plugin.start
    end
    
    specify "should be enabled" do
      @started_plugin.should_be_enabled
    end
    
    specify "should be started" do
      @started_plugin.should_be_started
    end
    
    specify "cannot be started" do
      lambda { @started_plugin.start }.should_raise Exceptions::PluginAlreadyStartedException
      @started_plugin.should_be_started
    end
  end
end
