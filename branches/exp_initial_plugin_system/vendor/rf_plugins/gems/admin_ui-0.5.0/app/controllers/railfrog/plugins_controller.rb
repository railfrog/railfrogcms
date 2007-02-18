class Railfrog::PluginsController < Railfrog::BaseController  
  def index
    @plugins = Plugin.find(:all)
  end
  
  def search
    installer = Gem::RemoteInstaller.new
    @result = installer.search(params[:name])
    @result.flatten!
  end
  
  def install
    RailFrogPluginAPI::install(params[:name], params[:version])
    redirect_to :action => 'index'
  end
  
  def uninstall
    RailFrogPluginAPI::uninstall(params[:name], params[:version])
    redirect_to :action => 'index'
  end
  
  def enable
    RailFrogPluginAPI::enable(params[:name], params[:version])
    redirect_to :action => 'index'
  end
  
  def disable
    RailFrogPluginAPI::disable(params[:name], params[:version])
    redirect_to :action => 'index'
  end
end
