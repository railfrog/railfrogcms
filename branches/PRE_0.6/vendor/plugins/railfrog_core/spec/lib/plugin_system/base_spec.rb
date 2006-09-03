require File.dirname(__FILE__) + '/../../spec_helper'

#FIXME: Remove 'railfrog_hello_world' directory as soon as it's not needed anymore
#       FileUtils.rm_rf(File.join(Engines.config(:root), "railfrog_hello_world"), :secure => true)
#TODO:  Refactor setup and teardown methods

context "The plugin system (in general)" do
  setup do
  end
end

context "The initialized plugin system with no installed and no registered plugins" do
  setup do
    @plugin_system = RailFrog::PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "no_plugins", "gems"))
    @plugin_system.init
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

context "The initialized plugin system with 3 installed but no registered plugins" do
  setup do
    @plugin_system = RailFrog::PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "data", "gems"))
    @plugin_system.init
  end
  
  specify "should have 3 installed plugins" do
    @plugin_system.should_have(3).installed_plugins
    @plugin_system.installed_plugins.should_include ["the_first_plugin", "0.0.1"]
    @plugin_system.installed_plugins.should_include ["another_plugin", "0.0.1"]
    @plugin_system.installed_plugins.should_include ["yet_another_plugin", "0.0.3"]
  end
  
  specify "should have registered the installed plugins (resulting in 3 registered plugins)" do
    @plugin_system.should_have(3).registered_plugins
  end
  
  teardown do
    @plugin_system.shutdown
  end
end

context "The initialized plugin system with no installed but 3 registered plugins" do
  fixtures :plugins
  
  setup do
    @plugin_system = RailFrog::PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "no_plugins", "gems"))
    @plugin_system.init
  end
  
  specify "should have no installed plugins" do
    @plugin_system.should_have(0).installed_plugins
  end
  
  specify "should have unregistered all uninstalled plugins (resulting in no registered plugins)" do
    @plugin_system.should_have(0).registered_plugins
  end
  
  teardown do
    @plugin_system.shutdown
  end
end

#TODO:  Plugin can only be enabled when all plugins it depends are enabled (create .enable(plugin), also .enabled?(plugin))
#TODO:  Plugin can only be disabled when all plugins that depend on it are disabled (create .disable(plugin), also .disabled?(plugin))
#TODO:  Plugin can only be started when all associated dependencies are met (create .start(plugin), also .started?(plugin))

context "The initialized plugin system with 3 installed and registered plugins (in general)" do
  fixtures :plugins
  
  setup do
    @plugin_system = RailFrog::PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "data", "gems"))
    @plugin_system.init
  end
  
  specify "should have 3 installed plugins" do
    @plugin_system.should_have(3).installed_plugins
  end
  
  specify "should have 3 registered plugins" do
    @plugin_system.should_have(3).registered_plugins
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

context "The plugin system with 3 installed and registered plugins (yet_another_plugin enabled)" do
  fixtures :plugins
  
  setup do
    @plugin_system = RailFrog::PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "data", "gems"))
    @plugin_system.init

    @yet_another_plugin = RailFrog::PluginSystem::Base.plugins("yet_another_plugin", "0.0.3")
    @yet_another_plugin.enable unless @yet_another_plugin.enabled?
    @another_plugin = RailFrog::PluginSystem::Base.plugins("another_plugin", "0.0.1")
       
    @plugin_system.startup
  end
  
  specify "should not have started any plugins" do
    @yet_another_plugin.should_not_be_started
    @another_plugin.should_not_be_started
  end
  
  teardown do
    @plugin_system.shutdown
  end
end

context "The started plugin system with 3 installed and registered plugins (yet_another_plugin and another_plugin enabled)" do
  fixtures :plugins
  
  setup do
    @plugin_system = RailFrog::PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "data", "gems"))
    @plugin_system.init
    
    @yet_another_plugin = RailFrog::PluginSystem::Base.plugins("yet_another_plugin", "0.0.3")
    @yet_another_plugin.enable unless @yet_another_plugin.enabled?
    @another_plugin = RailFrog::PluginSystem::Base.plugins("another_plugin", "0.0.1")
    @another_plugin.enable unless @another_plugin.enabled?
    
    @plugin_system.startup
  end
  
  specify "should have started the enabled plugins" do
    @yet_another_plugin.should_be_started
    @another_plugin.should_be_started
  end
  
  teardown do
    @plugin_system.shutdown
  end
end
