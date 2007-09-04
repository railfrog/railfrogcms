class ImageExt
  require 'cgi'
  def self.type; 'base'; end

	def generate_img_tag(	img_path, img_alt, img_id, img_class,
												img_length, img_height, img_style			)
		# Set up optional parameters
		id_string 		= (img_id.empty?) ? "" : ", :id => \"#{img_id}\""
		class_string 	= (img_class.empty?) ? "" : ", :class => \"#{img_class}\""
		size_string 	= (img_length.empty? or img_height.empty?) ?
										"" : ", :size => \"#{img_length}x#{img_height}\""
		style_string 	= (img_style.empty?) ? "" : ", :style => \"#{img_style}\""

		# Generate Rails image_tag
	  "<%= image_tag \"#{img_path}\", :alt => \"#{img_alt}\"" +
		"#{id_string}#{class_string}#{size_string}#{style_string} %>"
	end

	def validate_input(ext_item)
		# Check required fields
    ext_item.errors.add_on_empty(['img_path', 'img_alt'])

		# User should define both size paramters or none at all
		ext_item.errors.add_on_empty('img_length') if not ext_item.img_height.empty?
		ext_item.errors.add_on_empty('img_height') if not ext_item.img_length.empty?

		# Validate field formats
		ext_item.errors.add("Path field contains invalid characters!") \
			unless ext_item.img_path =~ /^([A-Za-z0-9\/\.])+$/
   	ext_item.errors.add("Length field contains invalid characters!") \
			unless ext_item.img_length =~ /^([0-9])*%?$/
   	ext_item.errors.add("Height field contains invalid characters!") \
			unless ext_item.img_height =~ /^([0-9])*%?$/
	end

  def edit_item(extension, item)
    ext_item = {}
		ext_item['img_path'] = item['img_path']
		ext_item['img_alt'] = item['img_alt']
		ext_item['img_id'] = item['img_id']
		ext_item['img_class'] = item['img_class']
		ext_item['img_length'] = item['img_length']
		ext_item['img_height'] = item['img_height']
		ext_item['img_style'] = item['img_style']
		ext_item['content'] = item['content']
    Theme::assign('ext_item', ext_item)
    Theme::render('edit_item')
  end

  def do_edit_item(extension, item, params)
    ext_item = params[:ext_item].clone
    ext_item.create_errors_object
		validate_input(ext_item)

    if ext_item.errors.count > 0 then
      Theme::assign('ext_item', ext_item)
      Theme::render('edit_item')
    end
    
		item['img_path'] = ext_item['img_path']
		item['img_alt'] = CGI.escapeHTML(ext_item['img_alt'])
		item['img_id'] = CGI.escapeHTML(ext_item['img_id'])
		item['img_class'] = CGI.escapeHTML(ext_item['img_class'])
		item['img_length'] = ext_item['img_length']
		item['img_height'] = ext_item['img_height']
		item['img_style'] = CGI.escapeHTML(ext_item['img_style'])
		item['content'] = \
			Theme::render_string(
				generate_img_tag(	item['img_path'], item['img_alt'], item['img_id'],
													item['img_class'], item['img_length'], item['img_height'],
													item['img_style']), :string => true											)
    Theme::render('editted_item')
  end

  def new_item(extension, item)
    ext_item = {}
    Theme::assign('ext_item', ext_item)
    Theme::render('new_item')
  end

  def create_item(extension, item, params)
    ext_item = params[:ext_item].clone
    ext_item.create_errors_object
		validate_input(ext_item)

    if ext_item.errors.count > 0 then
      Theme::assign('ext_item', ext_item)
      Theme::render('new_item')
      return
    end

		item['img_path'] = ext_item['img_path']
		item['img_alt'] = CGI.escapeHTML(ext_item['img_alt'])
		item['img_id'] = CGI.escapeHTML(ext_item['img_id'])
		item['img_class'] = CGI.escapeHTML(ext_item['img_class'])
		item['img_length'] = ext_item['img_length']
		item['img_height'] = ext_item['img_height']
		item['img_style'] = CGI.escapeHTML(ext_item['img_style'])
		item['content'] = \
			Theme::render_string(
				generate_img_tag(	item['img_path'], item['img_alt'], item['img_id'],
													item['img_class'], item['img_length'], item['img_height'],
													item['img_style']), :string => true											)
    item.finalize
    Theme::render('create_item')
  end

  def view(item)
    Theme::assign('item_contents', item.run_content(item['content']))
    Theme::render('view')
  end
end
