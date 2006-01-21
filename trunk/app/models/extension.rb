class Extension < ActiveRecord::Base
  attr :extklass
  @@extension_path = ''
  
  def name=(name); write_attribute 'name', name; end
  def ext_type=(ext_type); write_attribute 'ext_type', ext_type; end
  
  def after_initialize
    return if self.name.nil?
    load
  end
  
  def load
    load_result = load_file
    init_result = init_class

    return true
  end
  
  def method_missing(method_id, *args)
    unless @extklass.nil? then
      begin
        method_id = method_id.to_s[4..(method_id.to_s.length - 1)].to_sym if method_id.to_s[0..3] == 'ext_'
        meth = @extklass.method(method_id)
        return meth.call(*args) unless args.empty?
        return meth.call
      rescue NameError
        return super(method_id, *args)
      end
    end
    
    super(method_id, *args)
  end
  
  def run_method(method_name, *args)
    return method_missing(('ext_' + method_name.to_s).to_sym, *args)
  end
  
  def finalize
    self.temp = 0
    self.save!
    reload
    return true
  end
  
  def forward(method_name, *args)
    args.unshift(self)
    begin
      ret_value = ''
      Theme::extension(self.name) { ret_value = self.run_method(method_name, *args) }
      return ret_value
    rescue NoMethodError
      return false
    end
  end
  
  def info(reload = false)
    if reload or @yaml.nil?
      @yaml = Extension.load_yaml_data(self.name) 
      @yaml['name'] = self.name if @yaml['name'].empty?
    end
    
    return @yaml
  end
  
  def load_file
    return Extension.load_file(self.name)
  end
  
  def init_class
    @extklass = Extension.init_class(self.name)
  end
  
  def generate_filename
    return Extension.generate_filename(self.name)
  end
  
  def generate_classname
    return Extension.generate_classname(self.name)
  end
  
  class <<self    
    def load_file(ext_name)
      ext_name = generate_filename(ext_name)
      raise(ExtensionFileMissingException, ext_name.to_s) unless File.exists?(ext_name)
      require_dependency ext_name
      return true
    end
  
    def init_class(ext_name)
      ext_name = generate_classname(ext_name)
      begin
        extklass = nil
        eval 'extklass = ' + ext_name + '.new'
      rescue NameError
        raise(ExtensionNoClassException, ext_name)
      end
      
      return extklass
    end
  
    def set_path(path)
      return false unless File.exists?(path)
      @@extension_path = path
      return true
    end
    
    def path
      return @@extension_path
    end
    
    def exists?(extension_name)
      check_if_exists = find_by_name(extension_name)
      return true unless check_if_exists.nil?
      return false
    end
    
    def load_yaml_data(ext_name)
      raise(ExtensionYAMLDoesntExistException) unless File.exists?(yaml_name = generate_yaml_filename(ext_name))
      yaml_data = { 'name' => '', 'desc' => '', 'raw_name' => ext_name }
      File.open(yaml_name, 'r') do |file|
        yaml = YAML::load(file)
        break unless yaml
        yaml_data['name'] = yaml['name'].nil? ? '' : yaml['name']
        yaml_data['desc'] = yaml['desc'].nil? ? '' : yaml['desc']
      end
      
      return yaml_data
    end
    
    def install(ext_name)
      raise(ExtensionAlreadyInstalledException) if exists?(ext_name)
    
      newext = self.new
      newext.name = ext_name.to_s
      
      load_result = newext.load_file
      
      ext_name = newext.generate_classname
      @result = nil
      begin
        eval '@result = ' + ext_name + '.type'
      rescue NoMethodError
        raise(ExtensionUnknownTypeException)
      end
      
      raise(ExtensionUnknownTypeException, @result.to_s) unless @result == 'base' or @result == 'content'
      newext.ext_type = @result
      newext.temp = 1
      newext.save!
      newext.load
      return newext
    end
  
    def uninstall(ext_name)
      raise(ExtensionNotInstalledException, ext_name) unless exists?(ext_name)
      
      ext = find_by_name(ext_name)
      
      ext_name = generate_classname(ext_name)
      contents = ''
      begin
        Theme::extension(ext_name) { eval ext_name + '.uninstall' }
        contents = Theme::extension_contents
      rescue NoMethodError
      end
      
      Theme::assign('uninstall_notes', contents)
      ext.destroy
      return true
    end
      
    def generate_filename(ext_name)
      return @@extension_path + '/' + ext_name.downcase + '/' + ext_name.downcase + '_extension.rb'
    end
    
    def generate_yaml_filename(ext_name)
      return @@extension_path + '/' + ext_name.downcase + '/extension.yml'
    end
    
    def generate_classname(ext_name)
      return ext_name.downcase.camelize + 'Ext'
    end
  end
end
