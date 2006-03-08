class BaseExtensions < ActiveRecord::Migration
  VERSION = '003'

  def self.setup_path
    Extension.set_path(File.dirname(__FILE__) + '/../../extensions')
  end
  
  def self.extensions
    { 'Static'  => 'static',
      'Bold'    => 'bold' }
  end

  def self.up
    set_version(VERSION)
    log('Base Extensions')        
    
    setup_path
    extensions.each do |msg, name|
      log('Installing: ' + msg)
      Extension.install(name)
    end
    
    log('Done')
  end

  def self.down
    set_version(VERSION)
    log('Base Extensions Teardown')
    
    setup_path
    extensions.each do |msg, name|
      log('Removing: ' + msg)
      Extension.uninstall(name)
    end
    
    log('Done')
  end
end
