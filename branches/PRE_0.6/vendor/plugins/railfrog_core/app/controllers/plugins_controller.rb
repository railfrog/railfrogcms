class PluginsController < ApplicationController
  layout 'admin'
  
  def index
    list
    render :action => :list
  end
  
  def list
    @plugins = PluginSystem::Base.plugin_system.plugins.values
  end
  
  def enable
    PluginSystem::Base.plugin_system.plugins(params[:name], params[:version]).enable
    redirect_to :action => :list
  end
  
  def disable
    PluginSystem::Base.plugin_system.plugins(params[:name], params[:version]).disable
    redirect_to :action => :list
  end
  
  def start
    PluginSystem::Base.plugin_system.plugins(params[:name], params[:version]).start
    redirect_to :action => :list
  end
end
