module Theme
  @@theme_dir = nil
  @@theme = nil
  @@theme_assigns = {}
  @@renderer = nil
  @@rendered_file = nil
  @@extension = nil
  @@extension_contents = nil

  class <<self
    def extension_contents; @@extension_contents; end
    def extension(extension_name)
      @@extension = extension_name
      @@extension_contents = ''
      begin
        yield
      ensure
        @@extension = nil
      end
    end
  
    def set_renderer(meth)
      return false unless meth.kind_of?(Method) or meth.kind_of?(Proc)
      @@renderer = meth
      return true
    end
    
    def set_path(new_path)
      return false unless File.exists?(new_path)
      @@theme_dir = new_path
      return true
    end
    
    def set(theme = nil)
      if theme.nil? then
        @@theme = nil
        return true
      end
      
      return false if @@theme_dir.nil?
      return false unless File.exists?(@@theme_dir + '/' + theme)
      @@theme = theme
      return true
    end
    
    def set_file(file)
      @@rendered_file = file
    end
    
    def render(file, *options)
      return theme_render(file, *options) if @@extension.nil?
      options, assigned_string = check_string_in_options(options)
      
      retval = theme_render('extensions/' + @@extension + '/' + file, *options)
      retval = extension_render(file, *options) if retval === false
      return false if retval === false
      if assigned_string
        @@extension_contents += retval
        return true
      else
        return retval
      end
    end
    
    def render_string(contents, *options)
      return @@renderer.call(contents, *options) if @@extension.nil?
      options, assigned_string = check_string_in_options(options)
      
      retval = @@renderer.call(contents, *options)
      if assigned_string
        @@extension_contents += retval
        return true
      else
        return retval
      end
    end
    
    def check_string_in_options(options)
      assigned_string = false
      if !options[0].nil? then
        options[0] = {} unless options[0].kind_of?(Hash)
        unless !options[0][:string].nil? and options[0][:string] == true
          options[0][:string] = false
          assigned_string = true
        end
      else
        options = [{:string => true }]
        assigned_string = true
      end
      
      return [options, assigned_string]
    end
    
    def extension_render(file, *options)
      file_path = Extension.path + '/' + @@extension + '/views/' + file + '.rhtml'
      return false unless (contents = load_file(file_path))
      set_file(file)
      return @@renderer.call(contents, *options)
    end
    
    def theme_render(file, *options)
      return false if @@theme_dir.nil?
      return false if @@theme.nil?
      return false if @@renderer.nil?
      file_path = @@theme_dir + '/' + @@theme + '/' + file + '.rhtml'
      return false unless (contents = load_file(file_path))
      
      set_file(file)
      return @@renderer.call(contents, *options)
    end
    
    def load_file(file_path)
      return false unless File.exists?(file_path)
      fh = File.open(file_path, 'r')
      contents = fh.read
      fh.close
      return contents
    end
    
    def assign(key_name, value = nil)
      if key_name.kind_of?(String) then
        @@theme_assigns[key_name] = value
        return true
      end
      
      key_name.instance_variables.each do |name|
        @@theme_assigns[name[1,name.length]] = key_name.instance_variable_get(name.to_sym)
      end
    end
    
    def put_assigns_into(what_class)
      @@theme_assigns.each do |name,value|
        what_class.instance_variable_set(('@' + name).to_sym, value)
      end
    end
    
    def swap(new_theme)
      old_theme = current
      set(new_theme)
      yield
      set(old_theme)
    end
    
    def rendered_file; return @@rendered_file; end
    def get_assigns; return @@theme_assigns; end
    def get_path; return @@theme_dir; end
    def current; return @@theme; end
  end
end