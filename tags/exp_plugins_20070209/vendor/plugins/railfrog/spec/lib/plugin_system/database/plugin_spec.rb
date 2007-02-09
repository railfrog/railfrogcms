require File.dirname(__FILE__) + '/../../../spec_helper'

module PluginSystem::Database
  module PluginSpecHelper
    def valid_plugin_attributes
      { :name => 'bobs_crazy_plugin',
        :version => '1.0.0' }
    end
  end

  context "A plugin (in general)", :context_type => :model do
    include PluginSpecHelper
    
    setup do
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
      @plugin.version = 'abc'
      @plugin.should_not_be_valid
    end
    
    specify "should either be enabled or disabled" do
      Plugin.columns_hash['enabled'].type.should_be :boolean
    end
    
    specify "should be disabled by default" do
      @plugin.should_not_be_enabled
    end
    
    specify "can be enabled" do
      @plugin.update_attribute(:enabled, true).should_be true
    end
    
    specify "should be valid with a full set of valid attributes" do
      @plugin.attributes = valid_plugin_attributes
      @plugin.should_be_valid
    end
  end
  
  context "Two plugins with same name and version", :context_type => :model do
    include PluginSpecHelper
    
    setup do
      Plugin.create(valid_plugin_attributes)
      @plugin = Plugin.new(valid_plugin_attributes)
    end
  
    specify "cannot exist" do
      @plugin.should_not_be_valid
      @plugin.errors.on(:base).should == "The name-version pair of a plugin must be unique"
    end
  end
  
  context "Two plugins with same name and different version", :context_type => :model do
    include PluginSpecHelper
    
    setup do
      Plugin.create(valid_plugin_attributes.merge({ :enabled => true }))
      @plugin = Plugin.new(valid_plugin_attributes.merge({ :version => '2.0.0' }))
    end
    
    specify "cannot both be enabled" do
      @plugin.enabled = true
      @plugin.should_not_be_valid
      @plugin.errors.on(:base).should == "Only one version of a plugin may be enabled"
    end
  end
end