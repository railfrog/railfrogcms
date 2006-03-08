require_dependency 'admin_language_dropdown'

class Admin::RoleController < ApplicationController
  before_filter :check_admin
  menu({  'List' => 'index' })
  TEMPLATE_PATH = 'admin/role/'
  
  def index
    @roles = Role.find(:all)
    final_render(TEMPLATE_PATH + 'index')
  end
  
  def edit_language
    edit_language_shared
  end
  
  def edit_language_with_ajax
    @ajax = true
    edit_language_shared
  end
  
  def edit
    edit_shared
  end
  
  def edit_with_ajax
    @ajax = true
    edit_shared
  end
  
  def do_edit
    do_edit_shared
  end
  
  def do_edit_with_ajax
    @ajax = true
    do_edit_shared
  end
  
  def destroy_translation
    do_destroy_translation
  end
  
  def destroy_translation_with_ajax
    @ajax = true
    do_destroy_translation
  end
  
  def permissions
    permissions_shared
  end
  
  def permissions_with_ajax
    @ajax = true
    permissions_shared
  end
  
  def do_permissions
    do_permissions_shared
  end
  
  def do_permissions_with_ajax
    @ajax = true
    do_permissions_shared
  end
  
  def edit_parent
    edit_parent_shared
  end
  
  def edit_parent_with_ajax
    @ajax = true
    edit_parent_shared
  end
  
  private
  def edit_parent_shared
    @editrole = Role.find_by_id(params[:id])
    if !params[:editrole][:parent_id].to_s.empty?
      parent = Role.find_by_id(params[:editrole][:parent_id])
      @editrole.set_parent(parent)
      flash.now[:info] = 'role_parent_set'._tkey('system') / parent.translate
    else
      @editrole.remove_parent
      flash.now[:info] = 'role_parent_removed'._t('system')
    end
    edit_language_shared
  end
  
  def do_permissions_shared
    @editrole = Role.find_by_id(params[:id])
    perms = Permission.find(:all)
    perms.each { |perm| @editrole.set_permission(perm, params['permission_' + perm.id.to_s].to_i) }
    flash.now[:info] = 'role_permissions_saved'._tkey('system') / @editrole.translate
    return index
  end
  
  def permissions_shared
    @editrole = Role.find_by_id(params[:id])
    perms = Permission.find(:all)
    @permissions = []
    perms.each do |perm|
      newperm = {}
      newperm['id'] = perm.id
      newperm['name'] = perm.translate
      newperm['raw_name'] = perm.name
      newperm['value'] = @editrole.has_permission?(perm, true)
      @permissions.push(newperm)
    end
    
    final_render(TEMPLATE_PATH + 'permissions')
  end
  
  def do_destroy_translation
    @editrole = Role.find_by_id(params[:id])
    @editrole.remove_translation(params[:editlang])
    flash.now[:info] = 'role_translation_removed'._tkey('system') / params[:editlang]
    edit_language_shared
  end
  
  def do_edit_shared
    @editrole = Role.find_by_id(params[:id])
    @editrole.set(params[:editrole][:name], params[:editlang])
    flash.now[:info] = 'role_translation_saved'._tkey('system') / params[:editrole][:name]
    edit_language_shared
  end
  
  def edit_shared
    @editrole = Role.find_by_id(params[:id])
    @editrole.name = @editrole.translate(params[:editlang])
    final_render(TEMPLATE_PATH + 'edit')
  end
  
  def edit_language_shared
    @editrole = Role.find_by_id(params[:id])
    @languages = []
    Translation.find(:all, :conditions => ['tr_key = ?', Role.generate_unique_id(@editrole.id)]).each do |trans|
      lang = Language.find_by_id(trans.language_id)
      @languages.push({:name => lang.english_name, :translation => @editrole.translate(lang.iso_639_2), :code => lang.iso_639_2})
    end
    
    @parents = Role.find_all.collect { |r| [ r.translate, r.id ] unless r.id == @editrole.id }.compact
    
    final_render(TEMPLATE_PATH + 'edit_language')
  end
end
