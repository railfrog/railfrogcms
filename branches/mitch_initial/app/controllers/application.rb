# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  prepend_before_filter :setup
  layout 'layouts/default'
  
  def setup
    @ajax = false
  
    ::ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:database_manager => CGI::Session::PStore)
    ::ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:tmpdir => "#{RAILS_ROOT}/sessions/")
    ::ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:session_expires => 60.minutes.from_now)
    
    User.set_session(@session)
    @user = User.authenticate
    
    Extension.set_path(RAILS_ROOT + '/extensions') if RAILS_ENV != 'test'
    Theme::set_path(RAILS_ROOT + '/themes') if RAILS_ENV != 'test'
    Theme::set_renderer(self.method(:theme_render))
    Theme::set(params[:theme] || cookies[:theme] || Option.get('default_theme'))
    begin
      check = Locale.set(params[:lang] || cookies[:lang])
      raise(ArgumentError) if check.nil? or check.language.nil?
    rescue ArgumentError
      Locale.set(Option.get('default_language'))
    end
    
    @content_for_script = ''
    @extra_javascript = ''
    
    ExtensionAPI::Controller.add_method('final_render', method(:final_render))
  end
  
  def theme_render(contents, options = {})
    Theme::put_assigns_into self
    if contents.kind_of?(String) then
      return render(:inline => contents, :layout => false, *options) if options[:string].nil? or !options[:string]
      return render_to_string(:inline => contents)
    end
    
    contents[:layout] = false
    render(contents, *options) if options[:string].nil? or !options[:string]
    render_to_string(contents, *options)
  end
  
  def final_render(file, options = {})
    return '' if !options[:not_on_ajax].nil? and options[:not_on_ajax] and @ajax
    if !options[:string].nil? and options[:string]
      unless (value = Theme::render(file, options))
        value = render_to_string(file) 
        Theme::set_file(file)
      end
    else
      options[:layout] = false if @ajax

      unless Theme::render(file, options)
        value = render(file, options) 
        Theme::set_file(file)
      end
    end
    return value
  end
  
  def load_admin_nav
    Theme::assign('admin_navigation', AdminNavigationItem.enumerate)
  end
  
  def check_admin
    return true if RAILS_ENV == 'test'
    if @user.nil? or !@user.has_permission?('access_admin')
      render_text 'No'
      return false
    end
    
    load_admin_nav

    return true
  end
  
  def self.menu(menu_items)
    raise(ArgumentError) unless menu_items.kind_of?(Hash)
    menu_items.each do |name,options|
      if options.kind_of?(String) then
        menu_items[name] = { :action => options }
      end
    end
    Theme::assign('menu', menu_items)
  end
end