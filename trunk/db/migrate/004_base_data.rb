class BaseData < ActiveRecord::Migration
  VERSION = '004'

  def self.options
    { 'default_language'  => 'eng',
      'default_theme'     => 'system',
      'index'             => 'index',
      '404'               => '404' }
  end
  
  def self.phrases
    { #Error Messages for Form Validation
      'doesnt_exist'          => '%s doesn\'t exist.',
      'is_invalid'            => '%s is invalid.',
      'cant_be_empty'         => '%s can\'t be empty.',
      'system_error'          => 'A system error occured! Please notify a system administrator immediately.',
      
      # Admin Items Manager
      'renamed_item'          => 'Item renamed to: %s',
      'destroyed_item'        => 'Destroyed item: %s',
      'destroyed_multi_items' => 'Destroyed Selected Items',
      
      # Admin Extensions Manager
      'items_have_extension'  => 'You can\'t uninstall an extension until all items with the extension have been removed.',
      'installed_extension'   => 'The extension "%s" has been installed.',
      'uninstalled_extension' => 'The extension "%s" has been uninstalled.',
      
      # Admin Permissions Manager
      'perm_translation_saved'  => 'Translation changed to: %s',
      'perm_translation_removed' => 'Translation removed for language: %s',
      
      # Admin Role Manager
      'role_translation_saved'  => 'Translation changed to: %s',
      'role_translation_removed' => 'Translation removed for language: %s',
      'role_permissions_saved'  => 'Permissions saved for %s',
      'role_parent_set'       => 'Parent set to: %s',
      'role_parent_removed'   => 'Parent removed',
      
      # Admin Theme Manager
      'template_doesnt_exist' => 'The template you attempted to modify doesn\'t exist!',
      'template_unwritable'   => 'Unable to write to template "%s"! Please check write permissions.',
      'template_unreadable'   => 'Unable to read template "%s"! Please check read permissions.',
      'template_saved'        => '%s saved!',
      
      # Fields
      'login'                 => 'login' }
  end
  
  def self.roles
    { 'administrator'     => 'Administrator',
      'registered'        => 'Registered User',
      'guest'             => 'Guest' }
  end
  
  def self.permissions
    { 'access_admin'      => 'Access to Admin CP' }
  end
  
  def self.admin_nav
    { 'Items'             => 'item',
      'Extensions'        => 'extension',
      'Permissions'       => 'permission',
      'Roles'             => 'role',
      'Themes'            => 'theme' }
  end

  def self.up
    set_version(VERSION)
    log('Base Data')    
    log('Inserting system options...')    
    options.each { |key, value| Option.set(key, value) }
    
    log('Inserting system phrases...')
    Locale.set('eng')
    phrases.each { |key, value| key._t('system', value) }
    
    log('Inserting default roles...')
    roles.each { |name,trans| Role.set(name, trans) }
    Role.set_default('registered')
    
    log('Inserting default permissions...')
    permissions.each { |name, trans| Permission.set(name, trans) }
    
    log('Assigning default permissions to roles...')
    RolePermission.set('administrator', 'access_admin', 1)
    
    log('Inserting default system administrator.')
    log('User: admin Pass: admin')
    log('Don\'t forget to change this IMMEDIATELY!')
    newuser = User.new
    newuser.login = 'admin'
    newuser.password = 'admin'
    newuser.save!
    newuser.add_role(:administrator)
    
    log('Adding base admin navigation...')
    admin_nav.each { |text,controller| AdminNavigationItem.set(controller, text) }
    
    log('Done')
  end

  def self.down
    set_version(VERSION)
    log('Base Data Teardown')
    options.each { |key, value| Option.remove(key) }
    log('Done')
  end
end
