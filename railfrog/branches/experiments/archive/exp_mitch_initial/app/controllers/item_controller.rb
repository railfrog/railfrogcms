class ItemController < ApplicationController
  def load_item(name)
    return Item.find_by_name(name, :include => :extension)
  end

  def view_item
    params[:item] = Option.get('index') if params[:item].nil? or params[:item].empty?
    @item = load_item(params[:item])
    return error_404 if @item.nil?
    Theme::extension(@item.extension.name) { @item.ext_view(@item) }
    render_text Theme::extension_contents
  end
  
  def run_item
    item = load_item(params[:item])
    return error_404 if item.nil?
    render_text item.method_missing(('ext_' + params[:method]).to_sym)
  end
  
  def error_404
    item404 = load_item(Option.get('404'))
    if item404.nil? then
      render :inline => '404', :status => 404
      return
    end
    item404.ext_view(item404)
    render :text => Theme::extension_contents, :status => 404
  end
end
