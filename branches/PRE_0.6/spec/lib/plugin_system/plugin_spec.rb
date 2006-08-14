require File.dirname(__FILE__) + '/../../spec_helper'

context "A new Plugin object" do
  setup do
    #TODO: initialize @new_plugin
    @new_plugin = RailFrog::PluginSystem::Plugin.new
  end
  
  specify "should be a RailFrog::PluginSystem::Plugin" do
    @new_plugin.should_be_a_kind_of RailFrog::PluginSystem::Plugin
  end
  
  specify "should have a specification object" do
    @new_plugin.specification.should_not_be nil
  end
  
  specify "should be registered" do
    @registered_plugin.database.should_not_be nil
    @registered_plugin.database.should_be_kind_of Plugin
  end
end

context "A registered plugin" do
  setup do
    #TODO: initialize @registered_plugin
    @registered_plugin = RailFrog::PluginSystem::Plugin
  end
  
  specify "should either be enabled or disabled" do
    @registered_plugin.enabled?.should_be_a_kind_of Boolean
    @registered_plugin.disabled?.should_be_a_kind_of Boolean
    @registered_plugin.enabled?.should_not_be @registered_plugin.disabled?
  end
  
  specify "should either be started or not" do
    @registered_plugin.started?.should_be_a_kind_of Boolean
  end
end

context "An enabled plugin" do
  setup do
    #TODO: initialize @enabled_plugin
    @enabled_plugin = RailFrog::PluginSystem::Plugin.new
  end
  
  specify "should be enabled" do
    @enabled_plugin.should_be_enabled
    @enabled_plugin.should_not_be_disabled
    @enabled_plugin.database.should_be_enabled
  end
  
  specify "cannot be enabled" do
    lambda { @enabled_plugin.enabled }.should_raise PluginIsAlreadyEnabled
  end
  
  specify "can be started" do
    @enabled_plugin.start
    @enabled_plugin.should_be_started
  end
  
  specify "can be disabled" do
    @enabled_plugin.disable
    @enabled_plugin.should_not_be_enabled
    @enabled_plugin.should_be_disabled
    @enabled_plugin.database.should_not_be_enabled
    #TODO: is removed from engines root?
  end
  
  specify "cannot be uninstalled" do
    lambda { @enabled_plugin.uninstall }.should_raise CannotUninstallEnabledPlugin
    #TODO: check if still installed
  end
end

context "A disabled plugin" do
  setup do
    #TODO: initialize @disabled_plugin
    @disabled_plugin = RailFrog::PluginSystem::Plugin.new
  end
  
  specify "should be disabled" do
    @disabled_plugin.should_be_disabled
    @enabled_plugin.should_not_be_enabled
    @enabled_plugin.database.should_not_be_enabled
  end
  
  specify "cannot be disabled" do
    lambda { @disabled_plugin.disable }.should_raise PluginIsAlreadyDisabled
  end
  
  specify "cannot be started" do
    lambda { @disabled_plugin.start }.should_raise CannotStartDisabledPlugin
    @disabled_plugin.should_be_started
  end
  
  specify "can be enabled" do
    @disabled_plugin.enable
    @disabled_plugin.should_be_enabled
    @disabled_plugin.should_not_be_disabled
    @disabled_plugin.database.should_be_enabled
    #TODO: is copied to engines root?
  end
  
  specify "can be uninstalled" do
    lambda { @disabled_plugin.uninstall }.should_not_raise
    #TODO: check if really uninstalled
  end  
end

context "A started plugin" do
  setup do
    #TODO: initialize @started_plugin
    @started_plugin = RailFrog::PluginSystem::Plugin.new
  end
  
  specify "should be enabled" do
    @started_plugin.should_be_enabled
  end
  
  specify "should not be disabled" do
    @started_plugin.should_not_be_disabled
  end
  
  specify "should be started" do
    @started_plugin.should_be_started
  end
  
  specify "cannot be started" do
    lambda { @started_plugin.start }.should_raise PluginIsAlreadyStarted
  end
  
  specify "cannot be disabled" do
    lambda { @started_plugin.start }.should_raise CannotDisableStartedPlugin
  end
  
  specify "can have accessible controllers (that should behave as if they were in /app/controllers)" do
    #TODO:
    violated "test if controllers are accessible"
  end
    
  specify "can have accessible models (that should behave as if they were in /app/models)" do
    #TODO:
    violated "test if models are accessible"
  end
  
  specify "can have accessible helpers (that should behave as if they were in /app/helpers)" do
    #TODO:
    violated "test if helpers are accessible"
  end
  
  specify "can have accessible views (that should behave as if they were in /app/views)" do
    #TODO:
    violated "test if views are accessible"
  end

  specify "can have public files" do
    #TODO:
    violated "test if public files are public"    
  end
end
