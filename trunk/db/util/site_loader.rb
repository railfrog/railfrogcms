require File.dirname(__FILE__) + '/../../config/environment'
require File.dirname(__FILE__) + '/definition_loader'

#FIXME: Write help for SiteLoader usage
#FIXME: Load site from any given folder
# All layouts should be explictely defined in the site.yml 
# because loading order is important
class SiteLoader

  $SITE_YML = 'site.yml'

  def self.load_site(path2site)

    puts "Loading site from the '#{path2site}' dir"
    
    #FIXME: what is the best way to get Dir content
    Dir.chdir(path2site)

    #raise "No site definition file '#{$SITE_YML}' found in the #{path2site} dir" \
    #  unless File.readable_real?($SITE_YML)
    
    puts "  Loading site content from the site.yml"
    SiteDefinitionLoader.load_definition $SITE_YML
  
    puts "  Loading chunks from filesystem"
    Dir.chdir("pages/")
    load_content_chunks(SiteMapping.find_or_create_root)
  end

  def self.load_content_chunks(parent)
    # dropping '/' from the begining of the full path
    # to be able to load files from the current dir
    path = parent.full_path.sub(/^\//, '')

    # add '/' to the end of the dir name
    # to be able to do glob, eg Dir.glob('images/*')
    path = path + '/' unless path == ''

    # list all files in the given dir
    Dir.glob(path + '*').each { |filename| 
      path_segment = filename.split('/').last
      site_mapping = SiteMapping.find_or_create_by_parent_and_path_segment(parent, path_segment)
      if File.directory?(filename) then
        load_content_chunks site_mapping
      else
        load_content_chunk site_mapping
      end
    }
  end

  # Load chunk content from the file. The file name
  # we will get from the SiteMapping 
  def self.load_content_chunk(site_mapping)
    # FIXME: is better way to drop first '/' char
    #        then using sub(/^\//, '') call?
    # FIXME: this line already exists see line 22
    file = site_mapping.full_path.sub(/^\//, '')

    puts "    loading content of the chunk from file: '#{file}'"
    content = SiteDefinitionLoader.load_file_content(file)
    Chunk.find_or_create_by_site_mapping_and_content(site_mapping, content)
  end

end
