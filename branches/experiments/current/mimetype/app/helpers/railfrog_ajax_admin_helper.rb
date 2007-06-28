module RailfrogAjaxAdminHelper
  def add_window(page, window_id, url, options = {}, html_options = {})
    options[:className] = "alphacube"
    page << "var win = new Window( '#{window_id}', #{params_for_javascript(options) } ); win.setAjaxContent('#{url}'); win.show();  win.setDestroyOnClose();"
  end
end
