require_dependency 'area_finder_hash'

class Admin::ThemeController < ApplicationController
  before_filter :check_admin
  menu({  'List' => 'index' })
  TEMPLATE_PATH = 'admin/theme/'
  
  def index
    @themes = []
    
    Dir.foreach(Theme::get_path) do |theme|
      if File.exists?(Theme::get_path + '/' + theme + '/theme.yml') then
        yaml = YAML::load(File.open(Theme::get_path + '/' + theme + '/theme.yml', 'r'))
        yaml['id'] = theme
        yaml['active'] = Theme::current == theme
        @themes.push yaml
      end
    end
    
    @themes.sort! { |a,b| a['name'] <=> b['name'] }
    
    final_render(TEMPLATE_PATH + 'index')
  end
  
  def templates
    templates_shared
  end
  
  def templates_with_ajax
    @ajax = true
    templates_shared
  end
  
  def edit_template
    edit_template_shared
  end
  
  def edit_template_with_ajax
    @ajax = true
    edit_template_shared
  end
  
  def do_edit_template
    do_edit_template_shared
  end
  
  def do_edit_template_with_ajax
    @ajax = true
    do_edit_template_shared
  end
  
  def view_template
    view_template_shared
  end
  
  def view_template_with_ajax
    @ajax = true
    view_template_shared
  end
  
  def raw_view_template
    @theme = params[:edittheme]
    @edittemplate = params[:template]
    
    @areas = AreaHash.new
    Theme::swap(@theme) { final_render('templates/' + @edittemplate, :string => true) }
    @extra_javascript = ''
    @areas.areas.each_key do |area|
      @extra_javascript += render_to_string(:inline => '<%= drop_receiving_element("area-' + area + '", :url => { :action => "add" }, :loading => "Element.show(\'indicator\')", :complete => "Element.hide(\'indicator\')", :hoverclass => "area-hover") %>')
    end
    @areas = AreaHash.new
    Theme::swap(@theme) { final_render('templates/' + @edittemplate) }
  end
  
  private
  def view_template_shared
    return unless check_theme_and_template
    
    final_render(TEMPLATE_PATH + 'view_template')  
  end
  
  def do_edit_template_shared
    return unless check_theme_and_template
    
    File.open(@fpath, 'w') do |tfh|
      tfh.write(params[:template_contents])
    end
    
    flash.now[:info] = 'template_saved'._tkey('system') / @edittemplate
    return templates_shared(@theme)
  end
  
  def edit_template_shared
    return unless check_theme_and_template
    
    File.open(@fpath, 'r') do |tfh|
      if !tfh.stat.writable? then
        flash.now[:error] = 'template_unwritable'._tkey('system') / @edittemplate
        return templates_shared(@theme)
      elsif !tfh.stat.readable? then
        flash.now[:error] = 'template_unreadable'._tkey('system') / @edittemplate
        return templates_shared(@theme)
      end
      
      @template_contents = tfh.read
    end
    
    final_render(TEMPLATE_PATH + 'edit_template')
  end
  
  def check_theme_and_template
    @theme = params[:edittheme]
    @edittemplate = params[:template]

    @fpath = Theme::get_path.to_s + '/' + @theme + '/templates/' + @edittemplate + '.rhtml'
    if !File.exists?(@fpath) then
      flash.now[:error] = 'template_doesnt_exist'._t('system')
      templates_shared(@theme)
      return false
    end
    
    return true
  end
  
  def templates_shared(theme = params[:id])
    @theme = theme
    
    @templates = []
    Dir.foreach(Theme::get_path + '/' + @theme + '/templates') do |template|
      next unless template =~ /^(.+?).rhtml$/
      @templates.push($1)
    end
    
    @templates.sort!
    final_render(TEMPLATE_PATH + 'templates')
  end
end
