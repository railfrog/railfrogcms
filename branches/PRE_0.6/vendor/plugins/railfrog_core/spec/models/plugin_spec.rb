require File.dirname(__FILE__) + '/../spec_helper'

module PluginSpecHelper
  def valid_plugin_attributes
    { :name => 'bobs_crazy_plugin',
      :version => '1.0.0' }
  end
end

context "A plugin (in general)" do
  include PluginSpecHelper

  def setup
    @plugin = Plugin.new
  end

  specify "should be invalid without a name" do
    @plugin.attributes = valid_plugin_attributes.except(:name)
    @plugin.should_not_be_valid
  end

  specify "should be invalid without a version" do
    @plugin.attributes = valid_plugin_attributes.except(:version)
    @plugin.should_not_be_valid
  end
  
  specify "should be invalid with invalid version format" do
    @plugin.attributes = valid_plugin_attributes.except(:version)
    @plugin.version = "abc"
    @plugin.should_not_be_valid
  end
  
  specify "should either be enabled or disabled" do
    Plugin.columns_hash['enabled'].type.should_be :boolean
  end
  
  specify "should be disabled by default" do
    @plugin.should_not_be_enabled
  end
  
  specify "should be valid with a full set of valid attributes" do
    @plugin.attributes = valid_plugin_attributes
    @plugin.should_be_valid
  end
end


context "Two plugins with same name and version" do
  include PluginSpecHelper
  
  def setup
    Plugin.create(valid_plugin_attributes)
    @plugin = Plugin.new(valid_plugin_attributes)
  end

  specify "cannot exist" do
    @plugin.should_not_be_valid
    @plugin.errors.on(:base).should_equal "The name-version pair of a plugin must be unique"
  end
end

context "Two plugins with same name and different version" do
  specify "cannot both be enabled" do
    violated
  end
end
