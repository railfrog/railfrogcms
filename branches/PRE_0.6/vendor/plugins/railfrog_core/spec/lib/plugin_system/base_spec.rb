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

context "The started plugin system with 3 installed but no registered plugins" do
  setup do
    @plugin_system = RailFrog::PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "data", "gems"))
    @plugin_system.startup
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

context "The started plugin system with no installed but 3 registered plugins" do
  fixtures :plugins
  
  setup do
    @plugin_system = RailFrog::PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "no_plugins", "gems"))
    @plugin_system.startup
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

context "The started plugin system with 3 installed and registered (1 enabled) plugins" do
  fixtures :plugins
  
  setup do
    @plugin_system = RailFrog::PluginSystem::Base
    @plugin_system.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "data", "gems"))
    the_first_plugin_spec = File.join(RailFrog::PluginSystem::Base.root, "..", "specifications", "the_first_plugin-0.0.1.gemspec")
    the_first_plugin = RailFrog::PluginSystem::Plugin.new(the_first_plugin_spec)
    the_first_plugin.enable unless the_first_plugin.enabled?
    @plugin_system.startup
  end
  
  specify "should have 3 installed plugins" do
    @plugin_system.should_have(3).installed_plugins
  end
  
  specify "should have 3 registered plugins" do
    @plugin_system.should_have(3).registered_plugins
  end
  
  specify "should have started the enabled plugin" do
    #FIXME: test if a specific plugins is started instead of any
    @plugin_system.should_satisfy do |plugin_system|
      plugin_system.plugins.any? { |plugin| plugin.started? }
    end
  end
  
  teardown do
    @plugin_system.shutdown
  end
end
