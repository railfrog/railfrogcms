require File.dirname(__FILE__) + '/../../spec_helper'

context "A PluginSystem" do
  setup do
    @plugin_system = RailFrog::PluginSystem::Base.new
  end
  
  specify "should have more specifications" do
    violated "not enough specs"
  end
end
#
#context "The plugins list" do
#  setup do
#    @plugin_system = RailFrog::PluginSystem::Base.new
#    @plugins = @plugin_system.plugins
#  end
#  
#  specify "should be a Hash" do
#    @plugins.should_be_an_instance_of Hash
#  end
#  
#  specify "should have values that are descendants of RailFrog::PluginSystem::Plugin" do
#    #TODO?: Use first element of @plugins instead of iterating over all?
#    @plugins.each_value do |value|
#      value.should_be_a_kind_of RailFrog::PluginSystem::Plugin
#    end
#  end
#  
#  specify "should have keys of type Array with the structure [<plugin_name>,<plugin_version>]" do
#    #TODO?: Use first element of @plugins instead of iterating over all?
#    @plugins.each do |key, value|
#      key.should_be_an_instance_of Array
#      key[0].should_be_equal RailFrog::PluginSystem::Plugin.name
#      key[1].should_be_equal RailFrog::PluginSystem::Plugin.version.to_s
#    end
#  end
#  
#  specify "should be a list of all registered plugins" do
#  end
#end
