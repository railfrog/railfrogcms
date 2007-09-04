class ExtensionAPI
  module Theme
    def template_exists?(theme_name, template_name); Theme.template_exists?(theme_name, template_name); end
    
    class <<self
      def template_exists?(theme_name, template_name)
        return File.exists?(::Theme.get_path + '/' + theme_name + '/templates/' + template_name + '.rhtml')
      end
      
      def template_areas(theme_name, template_name)
        require_dependency 'area_finder_hash'
        return false unless template_exists?(theme_name, template_name)
        
        areas_hash = AreaHash.new
        ::Theme::assign('areas', areas_hash)
        ::Theme::swap(theme_name) { ExtensionAPI::Controller.final_render('templates/' + template_name, :string => true) }
        areas = []
        areas_hash.areas.each_key { |area| areas.push(area) }
        
        return areas
      end
    end
  end
end