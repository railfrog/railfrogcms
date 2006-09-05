require File.dirname(__FILE__) + '/../../spec_helper'

PluginSystem::Base.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "data"))

context "A dependency list with one plugin with no dependencies" do
  setup do
    another_plugin_spec = File.join(PluginSystem::Base.path_to_specs, "another_plugin-0.0.1.gemspec")
    @deps = PluginSystem::DependencyList.from_plugin_list(
              [PluginSystem::Plugin.new(another_plugin_spec)])
  end
  
  specify "should meet dependencies" do
    @deps.should_be_ok
  end
end

context "A dependency list with one plugin with (unmet) dependencies" do
  setup do
    yet_another_plugin_spec = File.join(PluginSystem::Base.path_to_specs, "yet_another_plugin-0.0.3.gemspec")
    @deps = PluginSystem::DependencyList.from_plugin_list([
              PluginSystem::Plugin.new(yet_another_plugin_spec)])
  end
  
  specify "should not meet dependencies" do
    @deps.should_not_be_ok
  end
end

context "A dependency list with two plugins with met dependencies" do
  setup do
    another_plugin_spec = File.join(PluginSystem::Base.path_to_specs, "another_plugin-0.0.2.gemspec")
    yet_another_plugin_spec = File.join(PluginSystem::Base.path_to_specs, "yet_another_plugin-0.0.3.gemspec")
    @deps = PluginSystem::DependencyList.from_plugin_list([
              @another_plugin = PluginSystem::Plugin.new(another_plugin_spec),
              @yet_another_plugin = PluginSystem::Plugin.new(yet_another_plugin_spec)])
  end
  
  specify "should meet dependencies" do
    @deps.should_be_ok
  end
  
  specify "should have dependency order 1) yet_another_plugin, 2) another_plugin" do
    @deps.dependency_order.should_equal [@yet_another_plugin.specification,
                                         @another_plugin.specification]
  end
end

context "A dependency list with two plugins with unmet dependencies" do
  setup do
    the_first_plugin_spec = File.join(PluginSystem::Base.path_to_specs, "the_first_plugin-0.0.1.gemspec")
    yet_another_plugin_spec = File.join(PluginSystem::Base.path_to_specs, "yet_another_plugin-0.0.3.gemspec")
    @deps = PluginSystem::DependencyList.from_plugin_list([
              PluginSystem::Plugin.new(the_first_plugin_spec),
              PluginSystem::Plugin.new(yet_another_plugin_spec)])
  end
  
  specify "should not meet dependencies" do
    @deps.should_not_be_ok
  end
end
