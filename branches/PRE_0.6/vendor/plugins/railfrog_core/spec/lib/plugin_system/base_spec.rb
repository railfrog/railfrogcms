require File.dirname(__FILE__) + '/../../spec_helper'

#FIXME: remove 'railfrog_hello_world' directory as soon as it's not needed anymore
#       FileUtils.rm_rf(File.join(Engines.config(:root), "railfrog_hello_world"), :secure => true)

context "The plugin system (in general)" do
  setup do
    @plugin_system = RailFrog::PluginSystem::Base
  end
end

context "The started plugin system with no installed and no registered plugins" do
  setup do
    @plugin_system = RailFrog::PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "no_plugins", "gems"))
    @plugin_system.startup
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

context "The started plugin system with 2 installed but no registered plugins" do
  setup do
    @plugin_system = RailFrog::PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "data", "gems"))
    @plugin_system.startup
  end
  
  specify "should have 2 installed plugins" do
    @plugin_system.should_have(2).installed_plugins
    @plugin_system.installed_plugins.should_include ["hello_universe", "0.0.3"]
    @plugin_system.installed_plugins.should_include ["hello_world", "0.0.1"]
  end
  
  specify "should have registered the installed plugins" do
    @plugin_system.should_have(2).registered_plugins
  end
  
  teardown do
    @plugin_system.shutdown
  end
end

context "The started plugin system with no installed but 2 registered plugins" do
  fixtures :plugins
  
  setup do
    @plugin_system = RailFrog::PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "no_plugins", "gems"))
    @plugin_system.startup
  end
  
  specify "should have no installed plugins" do
    @plugin_system.should_have(0).installed_plugins
  end
  
  specify "should have unregistered all uninstalled plugins" do
    @plugin_system.should_have(0).registered_plugins
  end
  
  teardown do
    @plugin_system.shutdown
  end
end

context "The started plugin system with 2 installed and registered (1 enabled) plugins" do
  fixtures :plugins
  
  setup do
    @plugin_system = RailFrog::PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "data", "gems"))
    helloworld_spec = File.join(RailFrog::PluginSystem::Base.root, "..", "specifications", "hello_world-0.0.1.gemspec")
    helloworld_plugin = RailFrog::PluginSystem::Plugin.new(helloworld_spec)
    helloworld_plugin.enable unless helloworld_plugin.enabled?
    @plugin_system.startup
  end
  
  specify "should have 2 installed plugins" do
    @plugin_system.should_have(2).installed_plugins
  end
  
  specify "should have 2 registered plugins" do
    @plugin_system.should_have(2).registered_plugins
  end
  
  specify "should have started the enabled plugin" do
    @plugin_system.should_satisfy do |plugin_system|
      plugin_system.plugins.any? {|plugin| plugin.started?}
    end
  end
  
  teardown do
    @plugin_system.shutdown
  end
end
