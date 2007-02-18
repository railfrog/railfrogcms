class Admin::ExtensionController < ApplicationController
  before_filter :check_admin
  menu({  'List' => 'index' })
  TEMPLATE_PATH = 'admin/extension/'
  
  def index
    load_extensions_array    
    final_render(TEMPLATE_PATH + 'index')
  end
  
  def finalize
    return index unless (ext = check_if_extension_exists(params[:id].to_s))
    return index unless ext.installed
    
    @extension = Extension.find_by_name(ext.raw_name)
    return index unless @extension.temp == 1
    @extension.finalize
    flash.now[:info] = 'installed_extension'._tkey('system') / @extension.info['name']
    return index
  end
  
  def install
    do_install
  end
  
  def install_ajax
    @ajax = true
    do_install
  end
  
  def uninstall
    do_uninstall
  end
  
  def uninstall_ajax
    @ajax = true
    do_uninstall
  end
  
  private
  def do_install
    return index unless (ext = check_if_extension_exists(params[:id].to_s))
    return index if ext.installed
    
    @extension = Extension.install(ext.raw_name)
    return finalize if @extension.forward('install') === false
    
    @extension_contents = Theme::extension_contents
    final_render(TEMPLATE_PATH + 'extension')
  end
  
  def do_uninstall
    return index unless (ext = check_if_extension_exists(params[:id].to_s))
    
    items = Item.find(:all)
    items.each do |item| 
      if item.has_extension?(ext.raw_name)
        flash.now[:error] = 'items_have_extension'._t('system')
        return index 
      end
    end
    
    flash.now[:info] = 'uninstalled_extension'._tkey('system') / Extension.find_by_name(ext.raw_name).info['name']
    Extension.uninstall(ext.raw_name)
    return index
  end
  
  def check_if_extension_exists(ext_name)
    load_extensions_array
    ext = @extensions.detect { |inext| inext.raw_name.downcase == ext_name.downcase }
    return false if ext.nil?
    ext
  end
  
  def load_extensions_array
    @extensions = []
    installed = Extension.find(:all)
    
    Dir.foreach(Extension.path) do |ext_file|
      installed_ext = installed.detect { |inext| inext.name.downcase == ext_file.downcase }
      if File.exists?(Extension.generate_filename(ext_file)) and File.exists?(Extension.generate_yaml_filename(ext_file)) then
        yaml_data = Extension.load_yaml_data(ext_file)
        yaml_data['installed'] = installed_ext.nil? ? false : true
        require_dependency Extension.generate_filename(ext_file)
        eval 'yaml_data[\'type\'] = ' + Extension.generate_classname(ext_file) + '.type'
        @extensions.push(yaml_data)
      end
    end
  end
end
