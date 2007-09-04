require File.dirname(__FILE__) + '/../../spec_helper'

module PluginSystem
  context "A new/empty PluginsList" do
    setup do
      @plugins_list = PluginsList.new
    end
    
    specify "should have no entries" do
      @plugins_list.should_have(0).entries
    end
    
    specify "should have an empty dependency order" do
      @plugins_list.dependency_order.should_be_empty
    end
    
    specify "can add a plugin to itself" do
      plugin = Plugin.new(File.join(@@__plugin_system_specs, 'another_plugin-0.0.1.gemspec'))
      @plugins_list.add plugin
      @plugins_list.should_include plugin
      @plugins_list.dependency_order.should_include plugin
    end
    
    specify "can add multiple plugins to itself" do
      specs = %w{the_first_plugin-0.0.1 another_plugin-0.0.2  yet_another_plugin-0.0.3}
      plugins = specs.map do |spec|
        Plugin.new(File.join(@@__plugin_system_specs, "#{spec}.gemspec"))
      end
      @plugins_list.add(*plugins)
      @plugins_list.entries.should_equal plugins
      @plugins_list.dependency_order.should_equal [plugins[0], plugins[2], plugins[1]]
    end
  end
  
  context "A PluginsList with one plugin" do
    setup do
      @plugin = Plugin.new(File.join(@@__plugin_system_specs, 'the_first_plugin-0.0.1.gemspec'))
      @plugins_list = PluginsList.new(@plugin)
    end
    
    specify "should have 1 entry" do
      @plugins_list.should_have(1).entries
    end
    
    specify "should find the plugin by it's full name" do
      @plugins_list[@plugin.full_name].should_not_be nil
    end
    
    specify "should be empty after 'clear'" do
      @plugins_list.clear
      @plugins_list.entries.should_be_empty
    end
    
    specify "should be empty after 'remove' of plugin" do
      @plugins_list.remove @plugin
      @plugins_list.entries.should_be_empty
    end
    
    specify "should have a dependency order" do
      @plugins_list.dependency_order.should_equal [@plugin]
    end
    
    specify "should have a load order" do
      @plugins_list.load_order.should_equal [@plugin]
    end
  end
  
  context "A PluginsList with multiple plugins" do
    setup do
      specs = %w{the_first_plugin-0.0.1 another_plugin-0.0.2  yet_another_plugin-0.0.3}
      @plugins = specs.map do |spec|
        Plugin.new(File.join(@@__plugin_system_specs, "#{spec}.gemspec"))
      end
      @plugins_list = PluginsList.new(*@plugins)
    end
    
    specify "should have 3 entries" do
      @plugins_list.should_have(3).entries
    end
    
    specify "should have a dependency order" do
      @plugins_list.dependency_order.should_equal [@plugins[0], @plugins[2], @plugins[1]]
    end
    
    specify "should have a load order" do
      @plugins_list.load_order.should_equal [@plugins[1], @plugins[2], @plugins[0]]
    end
    
    specify "can remove a plugin from itself" do
      plugin = @plugins[2]
      @plugins_list.remove plugin
      @plugins_list.should_not_include plugin
      @plugins_list.dependency_order.should_not_include plugin
    end
    
    specify "should be empty after 'clear'" do
      @plugins_list.clear
      @plugins_list.entries.should_be_empty
    end
  end
  
  context "A new/empty DynamicPluginsList" do
    setup do
      @dynamic_plugins_list = DynamicPluginsList.new(PluginsList.new, :some_filter)
    end
    
    specify "should have no entries" do
      @dynamic_plugins_list.should_have(0).entries
    end
    
    specify "should have an empty dependency order" do
      @dynamic_plugins_list.dependency_order.should_be_empty
    end
    
    specify "should be a kind of PluginsList" do
      @dynamic_plugins_list.should_be_a_kind_of PluginsList
    end
    
    specify "should not respond to 'add'" do
      @dynamic_plugins_list.should_not_respond_to :add
    end
    
    specify "should not respond to 'remove'" do
      @dynamic_plugins_list.should_not_respond_to :remove
    end
    
    specify "should not respond to 'clear'" do
      @dynamic_plugins_list.should_not_respond_to :clear
    end
  end
  
  context "A DynamicPluginsList that filters for enabled plugins with one enabled plugin" do
    setup do
      @plugin = Plugin.new(File.join(@@__plugin_system_specs, 'the_first_plugin-0.0.1.gemspec'))
      @plugin.stubs(:enabled?).returns(true)
      @dynamic_plugins_list = DynamicPluginsList.new(PluginsList.new(@plugin), :enabled?)
    end
    
    specify "should have 1 entry" do
      @dynamic_plugins_list.should_have(1).entries
    end
  end
  
  context "A DynamicPluginsList that filters for enabled plugins with one disabled plugin" do
    setup do
      @plugin = Plugin.new(File.join(@@__plugin_system_specs, 'the_first_plugin-0.0.1.gemspec'))
      @plugin.stubs(:enabled?).returns(false)
      @dynamic_plugins_list = DynamicPluginsList.new(PluginsList.new(@plugin), :enabled?)
    end
    
    specify "should have no entries" do
      @dynamic_plugins_list.should_have(0).entries
    end
  end
  
  context "A DynamicPluginsList that filters for enabled plugins with multiple plugins" do
    setup do
      specs = %w{the_first_plugin-0.0.1 another_plugin-0.0.2  yet_another_plugin-0.0.3}
      @plugins = specs.map do |spec|
        Plugin.new(File.join(@@__plugin_system_specs, "#{spec}.gemspec"))
      end
      @plugins_list = PluginsList.new(*@plugins)
    end
    
    specify "should have 3 entries" do
      @plugins_list.should_have(3).entries
    end
    
    specify "should have a dependency order" do
      @plugins_list.dependency_order.should_equal [@plugins[0], @plugins[2], @plugins[1]]
    end
    
    specify "should have a load order" do
      @plugins_list.load_order.should_equal [@plugins[1], @plugins[2], @plugins[0]]
    end
  end
end