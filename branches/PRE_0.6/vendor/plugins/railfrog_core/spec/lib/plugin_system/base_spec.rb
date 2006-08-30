require File.dirname(__FILE__) + '/../../spec_helper'

@plugin_system = RailFrog::PluginSystem::Base.instance

context "The started plugin system with no installed and no registered plugins" do
  setup do
  end
  
  specify "should have no installed plugins" do
    @plugin_system.installed_plugins.should_be_empty
  end
  
  specify "should have no registered plugins" do
    @plugin_system.registered_plugins.should_be_empty
  end
  
  specify "should have more specifications" do
    violated "not enough specs"
  end
end

context "The started plugin system with 2 installed but no registered plugins" do
  setup do
  end
  
  specify "should have 2 installed plugins" do
    @plugin_system.installed_plugins.size.should_be 2
  end
  
  specify "should have registered the installed plugins" do
    @plugin_system.registered_plugins.size.should_be 2
  end
  
  specify "should have more specifications" do
    violated "not enough specs"
  end
end

context "The started plugin system with no installed but <> registered plugins" do
  setup do
  end
  
  specify "should have no installed plugins" do
    @plugin_system.installed_plugins.should_be_empty
  end
  
  specify "should have unregistered all uninstalled plugins" do
    @plugin_system.registered_plugins.should_be_empty
  end
  
  specify "should have more specifications" do
    violated "not enough specs"
  end
end

context "The started plugin system with 2 installed and registered plugins" do
  setup do
  end
  
  specify "should have 2 installed plugins" do
    @plugin_system.installed_plugins.size.should_be 2
  end
  
  specify "should have 2 registered plugins" do
    @plugin_system.registered_plugins.size.should_be 2
  end
end
