module ActionController
  module Resources
    def railfrog_resources(*entities, &block)
      options = entities.last.is_a?(Hash) ? entities.pop : { }
      options[:name_prefix] = "railfrog_#{options[:name_prefix]}"
      options[:path_prefix] = "railfrog#{options[:path_prefix]}" unless options[:path_prefix] =~ /^(railfrog)/
      entities.each do |entity|
        options[:controller] = "railfrog/#{(options[:controller] || entity).to_s}"
        map_resource entity, options.dup, &block
        options[:controller] = nil
      end
    end
  end
end
