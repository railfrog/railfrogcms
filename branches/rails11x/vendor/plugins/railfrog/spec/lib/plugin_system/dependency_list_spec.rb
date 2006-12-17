require File.dirname(__FILE__) + '/../../spec_helper'

module PluginSystem
  context "A dependency list with one plugin with no dependencies" do
    setup do
      another_plugin_spec = File.join(@@__plugin_system_specs, 'another_plugin-0.0.1.gemspec')
      @deps = DependencyList.from_plugin_list([
                Plugin.new(another_plugin_spec)])
    end
    
    specify "should meet dependencies" do
      @deps.should_be_ok
    end
  end
  
  context "A dependency list with one plugin with (unmet) dependencies" do
    setup do
      yet_another_plugin_spec = File.join(@@__plugin_system_specs, 'yet_another_plugin-0.0.3.gemspec')
      @deps = DependencyList.from_plugin_list([
                Plugin.new(yet_another_plugin_spec)])
    end
    
    specify "should not meet dependencies" do
      @deps.should_not_be_ok
    end
  end
  
  context "A dependency list with two plugins with met dependencies" do
    setup do
      @plugins = ['another_plugin-0.0.2.gemspec', 'yet_another_plugin-0.0.3.gemspec'].map do |spec_file|
        Plugin.new(File.join(@@__plugin_system_specs, spec_file))
      end
      @deps = DependencyList.from_plugin_list(@plugins)
    end
    
    specify "should meet dependencies" do
      @deps.should_be_ok
    end
    
    specify "should have dependency order 1) yet_another_plugin, 2) another_plugin" do
      @deps.dependency_order.should_equal [@plugins[1].specification,
                                           @plugins[0].specification]
    end
  end
  
  context "A dependency list with two plugins with unmet dependencies" do
    setup do
      plugins = ['the_first_plugin-0.0.1.gemspec', 'yet_another_plugin-0.0.3.gemspec'].map do |spec_file|
        Plugin.new(File.join(@@__plugin_system_specs, spec_file))
      end
      @deps = DependencyList.from_plugin_list(plugins)
    end
    
    specify "should not meet dependencies" do
      @deps.should_not_be_ok
    end
  end
end
