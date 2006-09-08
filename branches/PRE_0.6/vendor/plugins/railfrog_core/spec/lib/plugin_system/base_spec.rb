require File.dirname(__FILE__) + '/../../spec_helper'

#TODO:  Refactor setup and teardown methods

context "The initialized plugin system with no installed and no registered plugins" do
  setup do
    @plugin_system = PluginSystem::Base.new(@@__no_plugins_root)
  end
  
  specify "should have no installed plugins" do
    @plugin_system.should_have(0).installed_plugins
  end
  
  specify "should have no registered plugins" do
    @plugin_system.should_have(0).registered_plugins
  end
end

context "The initialized plugin system with no installed but 4 registered plugins" do
  fixtures :plugins
  
  setup do
    @plugin_system = PluginSystem::Base.new(@@__no_plugins_root)
  end
  
  specify "should have no installed plugins" do
    @plugin_system.should_have(0).installed_plugins
  end
  
  specify "should have no registered plugins" do
    @plugin_system.should_have(0).registered_plugins
  end
  
  teardown do
    @plugin_system.shutdown
  end
end

#TODO:  Plugin can only be enabled when all plugins it depends are enabled (create .enable(plugin), also .enabled?(plugin))
#TODO:  Plugin can only be disabled when all plugins that depend on it are disabled (create .disable(plugin), also .disabled?(plugin))
#TODO:  Plugin can only be started when all associated dependencies are met (create .start(plugin), also .started?(plugin))

context "The initialized plugin system with 4 installed plugins (in general)" do
  setup do
    @plugin_system = PluginSystem::Base.new(@@__plugin_system_root)
  end
  
  specify "should have 4 installed plugins" do
    @plugin_system.should_have(4).installed_plugins
    [["another_plugin", "0.0.1"],
    ["another_plugin", "0.0.2"],
    ["the_first_plugin", "0.0.1"],
    ["yet_another_plugin", "0.0.3"]].each do |plugin|
      @plugin_system.installed_plugins.should_include plugin
    end
  end
  
  specify "should have 4 registered plugins" do
    @plugin_system.should_have(4).registered_plugins
    [["another_plugin", "0.0.1"],
    ["another_plugin", "0.0.2"],
    ["the_first_plugin", "0.0.1"],
    ["yet_another_plugin", "0.0.3"]].each do |plugin|
      @plugin_system.registered_plugins.should_include plugin
    end
  end
  
#  specify "can enable <plugin>" do
#  end
#  
#  specify "cannot enable <plugin>" do
#  end
#  
#  specify "can disable <plugin>" do
#  end
#  
#  specify "cannot disable <plugin>" do
#  end
#  
#  specify "can start <plugin>" do
#  end
#  
#  specify "cannot start <plugin>" do
#  end
end

context "The started plugin system with 4 installed plugins (yet_another_plugin enabled)" do
  setup do
    @plugin_system = PluginSystem::Base.new(@@__plugin_system_root)
    
    @yet_another_plugin = @plugin_system.plugins('yet_another_plugin', '0.0.3')
    @another_plugin = @plugin_system.plugins('another_plugin', '0.0.2')
    [@yet_another_plugin, @another_plugin].each do |plugin|
      FileUtils.rm_rf(plugin.path_to_engine, :secure => true)
    end
    @yet_another_plugin.enable if @yet_another_plugin.disabled?
    
    @plugin_system.start
  end
  
  specify "should not have started any plugins" do
    @yet_another_plugin.should_not_be_started
    @another_plugin.should_not_be_started
  end
  
  teardown do
    @plugin_system.shutdown
    FileUtils.rm_rf(@yet_another_plugin.path_to_engine, :secure => true)
  end
end

# This spec does fail because the plugin system doesn't know which version of
# another_plugin is enabled. 
context "The started plugin system with 4 installed plugins (yet_another_plugin and another_plugin enabled)" do
  setup do
    @plugin_system = PluginSystem::Base.new(@@__plugin_system_root)
    
    @yet_another_plugin = @plugin_system.plugins("yet_another_plugin", "0.0.3")
    @another_plugin = @plugin_system.plugins("another_plugin", "0.0.2")
    [@yet_another_plugin, @another_plugin].each do |plugin|
      FileUtils.rm_rf(plugin.path_to_engine, :secure => true)
      plugin.enable
    end
    
    @plugin_system.start
  end
  
  specify "should have started the enabled plugins" do
    @yet_another_plugin.should_be_started
    @another_plugin.should_be_started
  end
  
  teardown do
    @plugin_system.shutdown
    [@yet_another_plugin, @another_plugin].each do |plugin|
      FileUtils.rm_rf(plugin.path_to_engine, :secure => true)
    end
  end
end
