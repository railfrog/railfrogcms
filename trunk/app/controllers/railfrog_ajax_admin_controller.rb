class RailfrogAjaxAdminController < ApplicationController
  layout "ajaxified"

  def index
  end

  def start_app
    render :update do |page|
      add_window(page, 'site_explorer', url_for(:action => 'site_explorer'), { :title => 'Site Explorer', :top => 50, :left => 10, :width => 200, :height => 200 })
      add_window(page, 'labels', url_for(:action => 'labels'), { :title => 'Labels', :top => 50, :left => 215, :width => 400, :height => 100 })
    end
  end

  def site_explorer
    render :partial => 'site_explorer'
  end

  def labels
    render :text => 'labels'
  end

end

