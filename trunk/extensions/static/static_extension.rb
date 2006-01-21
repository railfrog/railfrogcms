class StaticExt
  def self.type; 'base'; end
  
  def edit_item(extension, item)
    ext_item = {}
    ext_item['content'] = item['content']
    Theme::assign('ext_item', ext_item)
    Theme::render('edit_item')
  end
  
  def do_edit_item(extension, item, params)
    ext_item = params[:ext_item].clone
    ext_item.create_errors_object
    ext_item.errors.add_on_empty('content')
    
    if ext_item.errors.count > 0 then
      Theme::assign('ext_item', ext_item)
      Theme::render('edit_item')
    end
    
    item['content'] = ext_item.content
    Theme::render('editted_item')
  end
  
  def new_item(extension, item)
    ext_item = {}
    Theme::assign('ext_item', ext_item)
    Theme::render('new_item')
  end
  
  def create_item(extension, item, params)
    ext_item = params[:ext_item].clone
    ext_item.create_errors_object
    ext_item.errors.add_on_empty('content')
    
    if ext_item.errors.count > 0 then
      Theme::assign('ext_item', ext_item)
      Theme::render('new_item')
      return
    end
    
    item['content'] = ext_item.content
    item.finalize
    Theme::render('create_item')
  end
  
  def view(item)
    Theme::assign('item_contents', item.run_content(item['content']))
    Theme::render('view')
  end
end