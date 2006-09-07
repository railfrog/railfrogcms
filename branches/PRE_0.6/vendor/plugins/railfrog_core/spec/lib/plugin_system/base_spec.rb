require File.dirname(__FILE__) + '/../../spec_helper'

#TODO:  Refactor setup and teardown methods

context "The initialized plugin system with no installed plugins" do
  setup do
    @plugin_system = PluginSystem::Base.new(File.join(
                       RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "no_plugins"))
  end
  
  specify "should have no installed plugins" do
    @plugin_system.should_have(0).installed_plugins
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
    @plugin_system.installed_plugins.should_equal([
      ["another_plugin", "0.0.1"],
      ["another_plugin", "0.0.2"],
      ["the_first_plugin", "0.0.1"],
      ["yet_another_plugin", "0.0.3"]])
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
    ["railfrog_yet_another_plugin", "railfrog_another_plugin"].each do |plugin|
      FileUtils.rm_rf(File.join(Engines.config(:root), plugin), :secure => true)
    end
        
    @plugin_system = PluginSystem::Base.new(@@__plugin_system_root)
    
    @yet_another_plugin = @plugin_system.plugins('yet_another_plugin', '0.0.3')
    @another_plugin = @plugin_system.plugins('another_plugin', '0.0.2')
    @yet_another_plugin.enable
    
    @plugin_system.start
  end
  
  specify "should not have started any plugins" do
    @yet_another_plugin.should_not_be_started
    @another_plugin.should_not_be_started
  end
  
  teardown do
    @plugin_system.shutdown
    FileUtils.rm_rf(File.join(Engines.config(:root), "railfrog_yet_another_plugin"), :secure => true)
  end
end

# This spec does fail because the plugin system doesn't know which version of
# another_plugin is enabled. 
context "The started plugin system with 4 installed plugins (yet_another_plugin and another_plugin enabled)" do
  setup do
    ["railfrog_yet_another_plugin", "railfrog_another_plugin"].each do |plugin|
      FileUtils.rm_rf(File.join(Engines.config(:root), plugin), :secure => true)
    end

    @plugin_system = PluginSystem::Base.new(@@__plugin_system_root)
    
    @yet_another_plugin = @plugin_system.plugins("yet_another_plugin", "0.0.3")
    @another_plugin = @plugin_system.plugins("another_plugin", "0.0.2")
    [@yet_another_plugin, @another_plugin].each { |plugin| plugin.enable }
    
    @plugin_system.start
  end
  
  specify "should have started the enabled plugins" do
    @yet_another_plugin.should_be_started
    @another_plugin.should_be_started
  end
  
  teardown do
    @plugin_system.shutdown
    ["railfrog_yet_another_plugin", "railfrog_another_plugin"].each do |plugin|
      FileUtils.rm_rf(File.join(Engines.config(:root), plugin), :secure => true)
    end
  end
end
