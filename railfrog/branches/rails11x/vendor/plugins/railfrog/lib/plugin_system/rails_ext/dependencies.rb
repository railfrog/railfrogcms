module Dependencies
  def depend_on(file_name, swallow_load_errors = false)
    paths = search_for_files(file_name)
    if paths
      paths.reverse.each {|path| require_or_load(path) }
    else
      require_or_load(file_name)
    end
  rescue LoadError
    raise unless swallow_load_errors
  end
  
  def search_for_files(path_suffix)
    path_suffix = path_suffix + '.rb' unless path_suffix.ends_with? '.rb'
    load_paths.inject(nil) do |paths, root|
      path = File.join(root, path_suffix)
      (paths ||= []) << path if File.file? path
      paths
    end
  end
  
  def load_missing_constant(from_mod, const_name)
    log_call from_mod, const_name
    if from_mod == Kernel
      if ::Object.const_defined?(const_name)
        log "Returning Object::#{const_name} for Kernel::#{const_name}"
        return ::Object.const_get(const_name)
      else
        log "Substituting Object for Kernel"
        from_mod = Object
      end
    end
    
    # If we have an anonymous module, all we can do is attempt to load from Object.
    from_mod = Object if from_mod.name.empty?
    
    unless qualified_const_defined?(from_mod.name) && from_mod.name.constantize.object_id == from_mod.object_id
      raise ArgumentError, "A copy of #{from_mod} has been removed from the module tree but is still active!"
    end
    
    raise ArgumentError, "Expected #{from_mod} is not missing constant #{const_name}!" if from_mod.const_defined?(const_name)
    
    qualified_name = qualified_name_for from_mod, const_name
    path_suffix = qualified_name.underscore
    name_error = NameError.new("uninitialized constant #{qualified_name}")
    
    file_paths = search_for_files(path_suffix)
    if file_paths
      file_paths.reverse.each do |file_path|
        require_or_load file_path unless loaded.include?(File.expand_path(file_path))
      end
      raise LoadError, "Expected one of #{file_paths.inspect} to define #{qualified_name}" unless from_mod.const_defined?(const_name)
      return from_mod.const_get(const_name)
    elsif mod = autoload_module!(from_mod, const_name, qualified_name, path_suffix)
      return mod
    elsif (parent = from_mod.parent) && parent != from_mod &&
          ! from_mod.parents.any? { |p| p.const_defined?(const_name) }
      # If our parents do not have a constant named +const_name+ then we are free
      # to attempt to load upwards. If they do have such a constant, then this
      # const_missing must be due to from_mod::const_name, which should not
      # return constants from from_mod's parents.
      begin
        return parent.const_missing(const_name)
      rescue NameError => e
        raise unless e.missing_name? qualified_name_for(parent, const_name)
        raise name_error
      end
    else
      raise name_error
    end
  end
end
