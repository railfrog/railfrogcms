require File.dirname(__FILE__) + '/../../spec_helper'

RailFrog::PluginSystem::Base.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "data", "gems"))

#FIXME: Just test from_plugin_list. Rest is done by rubygems.

context "A dependency list with one plugin and no dependencies" do
  setup do
    another_plugin_spec = File.join(RailFrog::PluginSystem::Base.root, "..", "specifications", "another_plugin-0.0.1.gemspec")
    plugins = [RailFrog::PluginSystem::Plugin.new(another_plugin_spec)]
    @deps = RailFrog::PluginSystem::DependencyList.from_plugin_list(plugins)
  end
  
  specify "should meet dependencies" do
    @deps.should_be_ok
  end
end

context "A dependency list with one plugin and (unmet) dependencies" do
  setup do
    yet_another_plugin_spec = File.join(RailFrog::PluginSystem::Base.root, "..", "specifications", "yet_another_plugin-0.0.3.gemspec")
    plugins = [RailFrog::PluginSystem::Plugin.new(yet_another_plugin_spec)]
    @deps = RailFrog::PluginSystem::DependencyList.from_plugin_list(plugins)
  end
  
  specify "should not meet dependencies" do
    @deps.should_not_be_ok
  end
end

context "A dependency list with two plugins and met dependencies" do
  setup do
    another_plugin_spec = File.join(RailFrog::PluginSystem::Base.root, "..", "specifications", "another_plugin-0.0.1.gemspec")
    yet_another_plugin_spec = File.join(RailFrog::PluginSystem::Base.root, "..", "specifications", "yet_another_plugin-0.0.3.gemspec")
    plugins = [@another_plugin = RailFrog::PluginSystem::Plugin.new(another_plugin_spec),
               @yet_another_plugin = RailFrog::PluginSystem::Plugin.new(yet_another_plugin_spec)]
    @deps = RailFrog::PluginSystem::DependencyList.from_plugin_list(plugins)
  end
  
  specify "should meet dependencies" do
    @deps.should_be_ok
  end
  
  specify "should have dependency order 1) yet_another_plugin, 2) another_plugin" do
    @deps.dependency_order.should_equal [@yet_another_plugin.specification,
                                         @another_plugin.specification]
  end
end

context "A dependency list with two plugins and unmet dependencies" do
  setup do
    the_first_plugin_spec = File.join(RailFrog::PluginSystem::Base.root, "..", "specifications", "the_first_plugin-0.0.1.gemspec")
    yet_another_plugin_spec = File.join(RailFrog::PluginSystem::Base.root, "..", "specifications", "yet_another_plugin-0.0.3.gemspec")
    plugins = [RailFrog::PluginSystem::Plugin.new(the_first_plugin_spec),
               RailFrog::PluginSystem::Plugin.new(yet_another_plugin_spec)]
    @deps = RailFrog::PluginSystem::DependencyList.from_plugin_list(plugins)
  end
  
  specify "should not meet dependencies" do
    @deps.should_not_be_ok
  end
end
