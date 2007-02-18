module RailFrogPluginAPI
  extend self
  
  Gem.manage_gems
  @@install_dir = File.join(RAILS_ROOT, "vendor", "rf_plugins")
  @@specifications_dir = File.join(@@install_dir, "specifications")
  @@plugin_root = Engines::config(:root)
  
  def setup
    @@source_index = Gem::SourceIndex.from_installed_gems(@@specifications_dir)
    plugins_in_db = Plugin.find(:all).map { |plugin| { :name => plugin.name, :version => plugin.version.to_s } }
    plugins_in_fs = find_plugins.map { |spec| { :name => spec.name, :version => spec.version.to_s } }
    added_plugins   = plugins_in_fs.delete_if { |plugin| plugins_in_db.include?(plugin) }
    deleted_plugins = plugins_in_db.delete_if { |plugin| plugins_in_fs.include?(plugin) }
    register added_plugins
  end
  
  def find_plugins
    @specs = []
    Gem::SourceIndex.from_installed_gems(@@specifications_dir).map do |path, spec|
      @specs << spec
    end
    @specs
  end
  
  def find_plugin(name, version='> 0')
    source_index = Gem::SourceIndex.from_installed_gems(@@specifications_dir)
    list = source_index.search(name, version)
    list[0]
  end
  
  def register(plugins)
    plugins.each do |plugin|
      Plugin.create(:name => plugin[:name], :version => plugin[:version], :enabled => false)
    end
  end
  
  def unregister(plugins)
    plugins.each do |plugin|
      Plugin.find_by_name_and_version(plugin[:name], plugin[:version]).destroy
    end
  end
  
  def install(name, version)
    # Install gem
    installer = Gem::RemoteInstaller.new
    installed_gems = installer.install(name, version, false, @@install_dir)
    installed_gems.map! { |gem| { :name => gem.name, :version => gem.version.to_s } }
    register(installed_gems)
  end
  
  def uninstall(name, version)
    # Migrate to version 0
    engine = Engines.get("railfrog_#{name}")
    unless engine.nil?
      Engines::EngineMigrator.current_engine = engine
      migration_directory = File.join(engine.root, 'db', 'migrate')
      if File.exist?(migration_directory)
        Engines::EngineMigrator.migrate(migration_directory, 0)
      end
      FileUtils.rm_rf engine.root
    end
    Plugin.find_by_name_and_version(name, version).destroy

    # Uninstall gem
    spec = find_plugin(name, version)
    raise Gem::FilePermissionError.new(spec.installation_path) unless File.writable?(spec.installation_path)
    FileUtils.rm_rf spec.full_gem_path
    FileUtils.rm_rf File.join(spec.installation_path,
                              'specifications',
                              "#{spec.full_name}.gemspec")
    FileUtils.rm_rf File.join(spec.installation_path,
                              'cache',
                              "#{spec.full_name}.gem")
#    Gem::DocManager.new(spec).uninstall_doc
  end
  
  def enable(name, version)
    plugin = Plugin.find_by_name_and_version(name, version)
    plugin.enabled = true
    plugin.save
  end
  
  def disable(name, version)
    plugin = Plugin.find_by_name_and_version(name, version)
    plugin.enabled = false
    plugin.save
  end
  
  def replace(name, old_version, new_version)
    disable(name, old_version)
    enable(name, new_version)
  end
  
  # Starts all enabled plugins. For more information see start.
  def start_enabled
    plugins = Plugin.find_enabled
    start(plugins)
  end
  
  def start(plugins)
    plugins.each do |plugin|
      source = File.join(@@install_dir, 'gems', "#{plugin.name}-#{plugin.version}")
      dest = File.join(@@plugin_root, "railfrog_#{plugin.name}")
      
      FileUtils.rm_rf dest if File.exists? dest
      FileUtils.cp_r source, dest
      
      Engines.start "railfrog_#{plugin.name}"
    end
  end
end