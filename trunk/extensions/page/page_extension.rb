class PageExt < ExtensionAPI::Base
  def self.type; 'base'; end
  
  def cmd_install(extension)
    print 'Creating DB schema...'
    ExtensionAPI::DB.migrate_up extension.name, 'page_schema', 'Page'
    puts 'Done'
    return true
  end
  
  def cmd_uninstall(extension)
    print 'Dropping DB schema...'
    ExtensionAPI::DB.migrate_down extension.name, 'page_schema', 'Page'
    puts 'Done'
    return true
  end
  
  def cmd_new_item(extension, item)
    print 'Template: '
    template = $stdin.gets.chomp
    unless ExtensionAPI::Theme.template_exists?(Theme.current, template)
      print "\n"
      puts "ERROR: Template #{template} doesn't exist!"
      return false
    end
    
    item['content'] = content
    return true
  end
  alias cmd_edit cmd_new_item
  
  def view(item)
    Theme::assign('item_contents', item.run_content(item['content']))
    Theme::render('view')
  end
end