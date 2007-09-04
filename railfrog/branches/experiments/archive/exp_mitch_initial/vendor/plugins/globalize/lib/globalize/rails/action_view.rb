# Search for translated templates or fall back to the default one
module ActionView # :nodoc: all
  class Base
    alias_method :globalize_old_render_file, :render_file

    @@globalize_path_cache = {}

    def render_file(template_path, use_full_path = true, local_assigns = {})
      if Globalize::Locale.active?
        localized_path = locate_globalize_path(template_path, use_full_path)

        # don't use_full_path -- we've already expanded the path
        globalize_old_render_file(localized_path, false, local_assigns)
      else 
        globalize_old_render_file(template_path, use_full_path, local_assigns)
      end
    end

    private
      def locate_globalize_path(template_path, use_full_path)
        active_locale = Globalize::Locale.active
        locale_code = active_locale.code

        cache_key = "#{locale_code}:#{template_path}"
        cached = @@globalize_path_cache[cache_key]
        return cached if cached

        if use_full_path
          template_extension = pick_template_extension(template_path)
          template_file_name = full_template_path(template_path, template_extension)
        else
          template_file_name = template_path
          template_extension = template_path.split('.').last
        end

        pn = Pathname.new(template_file_name)
        dir, filename = pn.dirname, pn.basename('.' + template_extension)

        # first try "en-US" style
        localized_path = dir + 
          (filename.to_s + '.' + locale_code + '.' + template_extension)

        catch :found do
          throw :found if localized_path.exist?

          # then try "en" style
          if active_language = Globalize::Locale.active.language 
            localized_path = dir + 
              (filename.to_s + '.' + active_language.code + 
              '.' + template_extension)
            throw :found if localized_path.exist?
          end

          # otherwise use default
          localized_path = template_file_name
        end

        @@globalize_path_cache[cache_key] = localized_path.to_s
      end

  end
end
