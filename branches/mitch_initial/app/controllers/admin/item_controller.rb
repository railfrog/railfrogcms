require_dependency 'admin_language_dropdown'

class Admin::ItemController < ApplicationController  
  before_filter :check_admin
  menu({  'List' => 'index',
          'Create' => 'new' })
  TEMPLATE_PATH = 'admin/item/'
  
  def index
    load_items
    @quick_edit_options = [['Select One', ''], ['Delete', 'delete'], ['Change Content Extensions', 'content']]
    final_render(TEMPLATE_PATH + 'index')
  end
  
  def do_quickedit_content
    process_quickedit_content
  end
  
  def do_quickedit_content_ajax
    @ajax = true
    process_quickedit_content
  end
  
  def new
    shared_new
    @newitem = Item.new
    @errors = ''
    final_render(TEMPLATE_PATH + 'new')
  end
  
  def quickedit
    do_quickedit
  end
  
  def quickedit_ajax
    @ajax = true
    do_quickedit
  end
  
  def do_rename
    process_rename
  end
  
  def do_rename_with_ajax
    @ajax = true
    process_rename
  end
  
  def edit
    edit_shared
  end
  
  def edit_with_ajax
    @ajax = true
    edit_shared
  end
  
  def edit_language
    edit_language_shared
  end
  
  def edit_language_ajax
    @ajax = true
    edit_language_shared
  end
  
  def destroy
    do_destroy
  end
  
  def destroy_with_ajax
    @ajax = true
    do_destroy
  end
  
  def create
    if do_create
      @item = @newitem
      unless forward_to_extension(@newitem.extension_id, 'new_item', @item)
        @newitem.temp = 0
        @newitem.save!
        final_render(TEMPLATE_PATH + 'create')
      end
    end
  end
  
  def create_with_ajax
    @ajax = true
    if do_create 
      @item = @newitem
      unless forward_to_extension(@newitem.extension_id, 'new_item', @item)
        @newitem.temp = 0
        @newitem.save!
        final_render(TEMPLATE_PATH + 'create')
      end
    end
  end
  
  def extension(item_id = params[:id], extension_id = params[:extension_id], method = params[:extension_method])
    do_extension_method(item_id, extension_id, method)
  end
  
  def extension_ajax(item_id = params[:id], extension_id = params[:extension_id], method = params[:extension_method])
    @ajax = true
    do_extension_method(item_id, extension_id, method)
  end
  
  private
  def load_items
    @items = Item.find(:all, :include => [:extension, :item_extensions])
  end
  
  def quickedit_delete
    load_items
    delete_ids = []
    @items.each { |item| item.destroy if params['item_' + item.id.to_s] == '1' }
    flash.now[:info] = 'destroyed_multi_items'._t('system')
    index
  end
  
  def get_edit_items
    load_items
    @edit_items = []
    @items.each { |item| @edit_items.push(item) if params['item_' + item.id.to_s] == '1' }
    return false if @edit_items.empty?
    return true
  end
  
  def process_quickedit_content
    return index unless get_edit_items
    
    shared_new
    @content_extensions.each do |ext|
      if params[:extensions_chosen]['content_' + ext.id.to_s] == '1' then
        @edit_items.each do |item|
          begin
            item.set_content_extension(ext)
          rescue ItemExtensionAlreadyExistsException
            #Yay, we rescued it! *Clap*
          end
        end
      else
        @edit_items.each { |item| item.unset_content_extension(ext) }
      end
    end
    
    index
  end
  
  def quickedit_content
    return index unless get_edit_items
    
    shared_new
    @content_extensions.each do |ext|
      chosen_key = 'content_' + ext.id.to_s
      final_value = false
      @edit_items.each do |item| 
        unless item.has_extension?(ext)
          final_value = false
          break
        end
        
        final_value = true
      end

      @extensions_chosen[chosen_key] = final_value
    end
    
    final_render(TEMPLATE_PATH + 'quickedit_content')
  end
  
  def do_quickedit
    begin
      meth = self.method(('quickedit_' + params[:quick_edit]).to_sym)
      meth.call
    rescue NameError
      render_text 'Invalid Selection'
    end
  end
  
  def process_complete_edit
    @item = @edititem
    forwarded = false
    Locale.swap(params[:editlang]) { forwarded = forward_to_extension(@edititem.extension_id, 'edit_item', @item) }
    final_render(TEMPLATE_PATH + 'editted') unless forwarded
  end
  
  def process_rename
    @edititem = Item.find_by_id(params[:id])
    return edit_language_shared if @edititem.name == params[:edititem][:name]
    @edititem.name = params[:edititem][:name]
    unless @edititem.valid?
      @errors = @edititem.errors
      flash[:rename_error] = final_render(TEMPLATE_PATH + 'new_error', :string => true)
      edit_language_shared
      return false
    end
    
    @edititem.save!
    flash[:rename_info] = 'renamed_item'._tkey('system') / @edititem.name
    edit_language_shared
    return true
  end
  
  def edit_shared
    @edititem = Item.find_by_id(params[:id])
    @item = @edititem
    retvalue = false
    Locale.swap(@params[:editlang]) { retvalue = forward_to_extension(@edititem.extension_id, 'edit_item', @item) }
    final_render(TEMPLATE_PATH + 'editted') unless retvalue
  end
  
  def edit_language_shared
    @edititem = Item.find_by_id(params[:id])
    @languages = []
    Translation.find(:all, :conditions => ['tr_key LIKE ?', Characteristic.generate_unique_id(@edititem.id, '%')]).each do |trans|
      lang = Language.find_by_id(trans.language_id)
      @languages.push({:name => lang.english_name, :code => lang.iso_639_2})
    end
    
    final_render(TEMPLATE_PATH + 'edit_language')
  end
  
  def do_destroy
    item = Item.find_by_id(params[:id])
    item.destroy
    flash.now[:info] = 'destroyed_item'._tkey('system') / item.name
    return index
  end
  
  def do_extension_method(item_id, extension_id, method)
    @item = Item.find_by_id(item_id)
    @extension = Extension.find_by_id(extension_id)
    Locale.swap(@params[:editlang]) { forward_to_extension(@extension.id, method, @item, params) }
  end

  def forward_to_extension(extension_id, method, *params)
    @extension = Extension.find_by_id(extension_id)
    return false if @extension.forward(method, *params) === false
    @extension_contents = Theme::extension_contents
    
    final_render(TEMPLATE_PATH + 'extension')
    return true
  end
  
  def shared_new
    @extensions = Extension.find_all_by_ext_type('base')
    @content_extensions = Extension.find_all_by_ext_type('content')
    @extensions_chosen = {}
  end
  
  def do_create
    @newitem = Item.new(params[:newitem])
    unless @newitem.valid?
      @errors = @newitem.errors
      flash[:error] = final_render(TEMPLATE_PATH + 'new_error', :string => true)
      shared_new
      final_render(TEMPLATE_PATH + 'new')
      return false
    end
    
    @newitem.temp = 1
    @newitem.save!
    
    return true if params[:extensions_chosen].nil?
    
    shared_new
    @extensions_chosen = params[:extensions_chosen].clone
    @content_extensions.each do |ext|
      @newitem.set_content_extension(ext) if @extensions_chosen['content_' + ext.id.to_s] == '1'
    end
    
    return true
  end
end
