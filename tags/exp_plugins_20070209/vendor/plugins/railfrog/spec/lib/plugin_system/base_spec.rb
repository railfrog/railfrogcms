require File.dirname(__FILE__) + '/../../spec_helper'

  module PluginSystem
  context "The initialized plugin system with no installed and no registered plugins" do
    setup do
      @plugin_system = Base.new(@@__no_plugins_root)
    end
    
    specify "should have no installed plugins" do
      @plugin_system.installed_plugins.should_have(0).entries
    end
    
    specify "should have no registered plugins" do
      @plugin_system.registered_plugins.should_have(0).entries
    end
  end
  
  context "The initialized plugin system with no installed but 2 registered plugins" do
    setup do
      #TODO: stub/mock this?
      Database::Plugin.create(:name => 'the_first_plugin', :version => '0.0.1')
      Database::Plugin.create(:name => 'another_plugin', :version => '0.0.1')
      @plugin_system = Base.new(@@__no_plugins_root)
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
      @plugin_system = Base.new(@@__plugin_system_root)
      @plugins = %w{another_plugin-0.0.1 another_plugin-0.0.2
                    the_first_plugin-0.0.1 without_files-1.0.0
                    yet_another_plugin-0.0.3}
    end
    
    specify "should have 5 installed plugins" do
      installed_plugins = @plugin_system.installed_plugins.map {|plugin| plugin.full_name }
      installed_plugins.sort.should == @plugins
    end
    
    specify "should have 5 registered plugins" do
      registered_plugins = @plugin_system.registered_plugins.map {|plugin| plugin.full_name }
      registered_plugins.sort.should == @plugins
    end
  end
  
  context "The started plugin system with the enabled plugin 'another_plugin-0.0.2'" do
    setup do
      @plugin_system = Base.new(@@__plugin_system_root)
      
      @another_plugin = @plugin_system.installed_plugins['another_plugin-0.0.2']
      @another_plugin.stub!(:enabled?).and_return(true)
      
      @plugin_system.start
    end
    
    specify "should have started the 'another_plugin-0.0.2'" do
      @another_plugin.should_be_started
    end
    
    teardown do
      @plugin_system.shutdown
    end
  end
  
  context "The started plugin system with the enabled plugin 'yet_another_plugin-0.0.3'" do
    setup do
      @plugin_system = Base.new(@@__plugin_system_root)
      
      @yet_another_plugin = @plugin_system.installed_plugins['yet_another_plugin-0.0.3']
      @yet_another_plugin.stub!(:enabled?).and_return(true)
      
      @plugin_system.start
    end
    
    specify "should not have started any plugins" do
      @yet_another_plugin.should_not_be_started
    end
    
    teardown do
      @plugin_system.shutdown
    end
  end
  
  context "The started plugin system with the enabled plugins 'yet_another_plugin-0.0.3' and 'another_plugin-0.0.2'" do
    setup do
      @plugin_system = Base.new(@@__plugin_system_root)
      
      @yet_another_plugin = @plugin_system.installed_plugins['yet_another_plugin-0.0.3']
      @another_plugin = @plugin_system.installed_plugins['another_plugin-0.0.2']
      @yet_another_plugin.stub!(:enabled?).and_return(true)
      @another_plugin.stub!(:enabled?).and_return(true)
      
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
end
