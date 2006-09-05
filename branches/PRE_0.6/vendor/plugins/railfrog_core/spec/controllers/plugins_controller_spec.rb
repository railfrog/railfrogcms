require File.dirname(__FILE__) + '/../spec_helper'

context "The PluginsController" do
  controller_name :plugins
  
  specify "should be a PluginsController" do
    controller.should_be_an_instance_of PluginsController
  end
end

context "Rendering /person" do
  controller_name :plugins

  setup do
    get 'index'
  end

  specify "should render 'list'" do
    response.should_render :list
  end
end
