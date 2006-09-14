require File.dirname(__FILE__) + '/../../spec_helper'

context "The initialized plugin system with no installed and no registered plugins" do
  setup do
    @plugin_system = PluginSystem::Base.new(@@__no_plugins_root)
  end
  
  specify "should have no installed plugins" do
    @plugin_system.installed_plugins.should_have(0).entries
  end
  
  specify "should have no registered plugins" do
    @plugin_system.registered_plugins.should_have(0).entries
  end
end

context "The initialized plugin system with no installed but 2 registered plugins" do
  fixtures :plugins
  
  setup do
    @plugin_system = PluginSystem::Base.new(@@__no_plugins_root)
  end
  
  specify "should have no installed plugins" do
    @plugin_system.installed_plugins.should_have(0).entries
  end
  
  specify "should have no registered plugins" do
    @plugin_system.registered_plugins.should_have(0).entries
  end
  
  teardown do
    @plugin_system.shutdown
  end
end

context "The initialized plugin system with 5 installed plugins (in general)" do
  setup do
    @plugin_system = PluginSystem::Base.new(@@__plugin_system_root)
    @plugins = %w{another_plugin-0.0.1 another_plugin-0.0.2
                  the_first_plugin-0.0.1 without_files-1.0.0
                  yet_another_plugin-0.0.3}
  end
  
  specify "should have 5 installed plugins" do
    installed_plugins = @plugin_system.installed_plugins.map {|plugin| plugin.full_name }
    installed_plugins.sort.should_equal @plugins
  end
  
  specify "should have 5 registered plugins" do
    registered_plugins = @plugin_system.registered_plugins.map {|plugin| plugin.full_name }
    registered_plugins.sort.should_equal @plugins
  end
end

context "The initialized plugin system with disabled plugins" do
  setup do
    @plugin_system = PluginSystem::Base.new(@@__plugin_system_root)
  end
  
  specify "can enable 'the_first_plugin-0.0.1'" do
    @plugin_system.enable_plugin('the_first_plugin-0.0.1')
    @plugin_system.enabled_plugins['the_first_plugin-0.0.1'].should_be_enabled
  end
end

context "The initialized plugin system with the enabled plugin 'the_first_plugin-0.0.1' (all other plugins disabled)" do
  setup do
    @plugin_system = PluginSystem::Base.new(@@__plugin_system_root)
    @plugin_system.enable_plugin('the_first_plugin-0.0.1')
  end
  
  specify "can disable 'the_first_plugin-0.0.1'" do
    @plugin_system.disable_plugin('the_first_plugin-0.0.1')
    @plugin_system.disabled_plugins['the_first_plugin-0.0.1'].should_be_disabled
  end
  
  specify "can start 'the_first_plugin-0.0.1'" do
    @plugin_system.start_plugin('the_first_plugin-0.0.1')
    @plugin_system.started_plugins['the_first_plugin-0.0.1'].should_be_started
  end
end

context "The initialized plugin system with the started plugin 'the_first_plugin-0.0.1' (all other plugins disabled)" do
  setup do
    @plugin_system = PluginSystem::Base.new(@@__plugin_system_root)
    @plugin_system.enable_plugin('the_first_plugin-0.0.1')
    @plugin_system.start_plugin('the_first_plugin-0.0.1')
  end
  
  specify "can stop 'the_first_plugin-0.0.1'" do
    @plugin_system.stop_plugin('the_first_plugin-0.0.1')
    @plugin_system.enabled_plugins['the_first_plugin-0.0.1'].should_not_be_started
  end
end

context "The started plugin system with the enabled plugin 'yet_another_plugin-0.0.3' (all other plugins disabled)" do
  setup do
    @plugin_system = PluginSystem::Base.new(@@__plugin_system_root)
    
    @yet_another_plugin = @plugin_system.installed_plugins['yet_another_plugin-0.0.3']
    @plugin_system.enable_plugin('yet_another_plugin-0.0.3')
    
    @plugin_system.start
  end
  
  specify "should not have started any plugins" do
    @yet_another_plugin.should_not_be_started
  end
  
  teardown do
    @plugin_system.shutdown
  end
end

context "The started plugin system with the enabled plugins 'yet_another_plugin-0.0.3' and 'another_plugin-0.0.2' (all other plugins disabled)" do
  setup do
    @plugin_system = PluginSystem::Base.new(@@__plugin_system_root)
    
    @yet_another_plugin = @plugin_system.installed_plugins['yet_another_plugin-0.0.3']
    @another_plugin = @plugin_system.installed_plugins['another_plugin-0.0.2']
    @plugin_system.enable_plugin('yet_another_plugin-0.0.3')
    @plugin_system.enable_plugin('another_plugin-0.0.2')
    
    @plugin_system.start
  end
  
  specify "should have started the enabled plugins" do
    @yet_another_plugin.should_be_started
    @another_plugin.should_be_started
  end
  
  teardown do
    @plugin_system.shutdown
  end
end
