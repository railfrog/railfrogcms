class ApplicationController
  def auto_complete_for_language
    lang = nil
    lang = params[:editlang] unless params[:editlang].nil?
    
    return if lang.nil?
    @languages = Language.find(:all, 
      :conditions => ['english_name LIKE ?', '%' + lang + '%'], 
      :order => 'english_name ASC', :limit => 6)
    
    final_render('language_dropdown')
  end
  
  def url_for_auto_complete_language
    url_for :controller => '/admin/item', :action => 'auto_complete_for_language'
  end
  
  helper_method :url_for_auto_complete_language
end