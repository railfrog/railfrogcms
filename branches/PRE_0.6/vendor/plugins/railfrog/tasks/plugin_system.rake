require File.expand_path(File.join(RAILS_ROOT, 'config', 'environment'))

if Object.const_defined?('PluginSystem')
  PluginSystem::Instance.enabled_plugins.each do |plugin|
    Dir[File.join(plugin.path_to_gem, 'tasks', '**', '*.rake')].sort.each { |ext| load ext }
  end
  
  namespace :db do
    namespace :migrate do
      namespace :railfrog_plugin do
        PluginSystem::Instance.enabled_plugins.group_by(&:name).each do |name, plugins|
          desc "Migrate the plugin '#{name}'."
          task name do
            if plugins.size > 1
              puts <<END_OF_TEXT
NOTE: Currently you can only migrate to a newer version of a plugin. Migrating
      down to an older version won't work properly.

Select the version to which you want to migrate to:
END_OF_TEXT
              plugins.each_with_index do |plugin, index|
                puts " #{index+1}) #{plugin.full_name}"
              end
              puts
              print "Select: "
              selection = STDIN.gets
              plugin = plugins[selection.to_i-1]
            else
              plugin = plugins.first
            end
            puts "Migrating to version #{plugin.version}..."
            PluginSystem::Migrator.plugin_name = plugin.name
            PluginSystem::Migrator.migrate(File.join(plugin.path_to_gem, 'db', 'migrate/'), nil)
            Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
          end
        end
      end
    end
  end
  
  # FIXME: The 'begin .. rescue' is only a temporary fix for cases where rspec is not present.
  begin 
    require 'spec/rake/spectask'
    namespace :spec do
      namespace :railfrog_plugins do
        PluginSystem::Instance.installed_plugins.each do |plugin|
          namespace plugin.full_name do
            if File.directory?("#{plugin.path_to_gem}/spec/models")
              desc "Run the specs under #{plugin.path_to_gem}/spec/models"
              Spec::Rake::SpecTask.new(:models => "db:test:prepare") do |t|
                t.spec_files = FileList["#{plugin.path_to_gem}/spec/models/**/*_spec.rb"]
              end
            end
            
            if File.directory?("#{plugin.path_to_gem}/spec/controllers")      
              desc "Run the specs under #{plugin.path_to_gem}/spec/controllers"
              Spec::Rake::SpecTask.new(:controllers => "db:test:prepare") do |t|
                t.spec_files = FileList["#{plugin.path_to_gem}/spec/controllers/**/*_spec.rb"]
              end
            end
          end
        end
      end
    end
  rescue
  end
end