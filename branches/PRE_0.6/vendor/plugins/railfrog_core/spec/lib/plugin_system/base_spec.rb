require File.dirname(__FILE__) + '/../../spec_helper'

#FIXME: Remove 'railfrog_hello_world' directory as soon as it's not needed anymore
#       FileUtils.rm_rf(File.join(Engines.config(:root), "railfrog_hello_world"), :secure => true)
#TODO:  Refactor setup and teardown methods

context "The initialized plugin system with no installed plugins" do
  setup do
    @plugin_system = PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "no_plugins"))
    @plugin_system.init
  end
  
  specify "should have no installed plugins" do
    @plugin_system.should_have(0).installed_plugins
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
    @plugin_system = PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "data"))
    @plugin_system.init
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
    
  teardown do
    @plugin_system.shutdown
  end
end

context "The started plugin system with 4 installed plugins (yet_another_plugin enabled)" do
  setup do
    @plugin_system = PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "data"))
    @plugin_system.init

    @yet_another_plugin = PluginSystem::Base.plugins("yet_another_plugin", "0.0.3")
    @yet_another_plugin.enable
    @another_plugin = PluginSystem::Base.plugins("another_plugin", "0.0.2")
       
    @plugin_system.startup
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

context "The started plugin system with 4 installed plugins (yet_another_plugin and another_plugin enabled)" do
  setup do
    @plugin_system = PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "data"))
    @plugin_system.init
    
    @yet_another_plugin = PluginSystem::Base.plugins("yet_another_plugin", "0.0.3")
    @yet_another_plugin.enable
    @another_plugin = PluginSystem::Base.plugins("another_plugin", "0.0.2")
    @another_plugin.enable
    
    @plugin_system.startup
  end
  
  specify "should have started the enabled plugins" do
    @yet_another_plugin.should_be_started
    @another_plugin.should_be_started
  end
  
  teardown do
    @plugin_system.shutdown
    FileUtils.rm_rf(File.join(Engines.config(:root), "railfrog_yet_another_plugin"), :secure => true)
    FileUtils.rm_rf(File.join(Engines.config(:root), "railfrog_another_plugin"), :secure => true)
  end
end
