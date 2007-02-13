# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  # config.action_controller.session_store = :active_record_store

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"

  # Activate observers that should always be running
  #config.active_record.observers = :cacher #, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
   config.active_record.schema_format = :ruby

  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below

ActionController::Base.perform_caching = true

        XINHA_RUNNER_SCRIPT =<<END_OF_SCRIPT

        //
        // the code snippet got from the http://xinha.gogo.co.nz/punbb/viewtopic.php?id=651
        //

        // array for editors
        xinha_editors = new Array();

        // array for plugins
        xinha_editors_plugins = new Array();

        var xinha_text_area = 'XinhaTextArea';
        // make it a new element in the xinha_editors-array
        xinha_editors.push(xinha_text_area);

        // also in the plugins-array
        xinha_editors_plugins.push(xinha_text_area);
        xinha_editors_plugins[xinha_text_area] = [
          'CharacterMap', 'ContextMenu', 'FullScreen',
          'ListType', 'SpellChecker', 'Stylist',
          'SuperClean', 'TableOperations'];

        // make the editors
        xinha_editors   = HTMLArea.makeEditors(xinha_editors, xinha_config);

        // set the plugins for the editors
        xinha_editors[xinha_text_area].registerPlugins(xinha_editors_plugins[xinha_text_area]);

        // show the editor
        HTMLArea.startEditors(xinha_editors);
END_OF_SCRIPT
