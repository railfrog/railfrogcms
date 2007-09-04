require_dependency 'admin_language_dropdown'

class Admin::PermissionController < ApplicationController
  before_filter :check_admin
  menu({  'List' => 'index' })
  TEMPLATE_PATH = 'admin/permission/'
  
  def index
    @permissions = Permission.find(:all)
    final_render(TEMPLATE_PATH + 'index')
  end
  
  def destroy_translation
    do_destroy_translation
  end
  
  def destroy_translation_with_ajax
    @ajax = true
    do_destroy_translation
  end
  
  def do_edit
    do_edit_shared
  end
  
  def do_edit_with_ajax
    @ajax = true
    do_edit_shared
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
  
  def edit_language_with_ajax
    @ajax = true
    edit_language_shared
  end
  
  private
  def do_destroy_translation
    @editperm = Permission.find_by_id(params[:id])
    @editperm.remove_translation(params[:editlang])
    flash.now[:info] = 'perm_translation_removed'._tkey('system') / params[:editlang]
    edit_language_shared
  end
  
  def do_edit_shared
    @editperm = Permission.find_by_id(params[:id])
    @editperm.set(params[:editperm][:name], params[:editlang])
    flash.now[:info] = 'perm_translation_saved'._tkey('system') / params[:editperm][:name]
    edit_language_shared
  end
  
  def edit_shared
    @editperm = Permission.find_by_id(params[:id])
    @editperm.name = @editperm.translate(params[:editlang])
    final_render(TEMPLATE_PATH + 'edit')
  end
  
  def edit_language_shared
    @editperm = Permission.find_by_id(params[:id])
    @languages = []
    Translation.find(:all, :conditions => ['tr_key = ?', Permission.generate_unique_id(@editperm.id)]).each do |trans|
      lang = Language.find_by_id(trans.language_id)
      @languages.push({:name => lang.english_name, :translation => @editperm.translate(lang.iso_639_2), :code => lang.iso_639_2})
    end
    
    final_render(TEMPLATE_PATH + 'edit_language')
  end
end
