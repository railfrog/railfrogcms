class RailfrogAjaxAdminController < ApplicationController
  layout "ajaxified"

  def index
  end

  def start_app
    render :update do |page|
      add_window(page, 'site_explorer', url_for(:action => 'site_explorer'), { :title => 'Site Explorer', :top => 55, :left => 3, :width => 200, :height => 200 })
      add_window(page, 'labels', url_for(:action => 'labels'), { :title => 'Labels', :top => 55, :left => 220, :width => 400, :height => 100 })
    end
  end

  def site_explorer
    render :partial => 'site_explorer', :locals => { :site_mapping => SiteMapping.root }
  end

  def change_dir
    if request.xhr?
      render :update do |page|
        page.replace_html :site_explorer_pane, :partial => 'site_explorer_pane', :locals => { :site_mapping => SiteMapping.find(params[:id]) }
      end
    end
  end

  def labels
    render :text => 'labels'
  end

end

