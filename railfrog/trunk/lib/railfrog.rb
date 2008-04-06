require File.dirname(__FILE__) + '/railfrog/transform/transform_manager'
require File.dirname(__FILE__) + '/railfrog/transform/base_transformer'
require File.dirname(__FILE__) + '/railfrog/transform/maruku_transformer'
require File.dirname(__FILE__) + '/railfrog/transform/red_cloth_transformer'
require File.dirname(__FILE__) + '/railfrog/mime_type/tools'

Railfrog::MimeType::Tools.lazy_load
tm = Railfrog::Transform::TransformManager.instance
tm.register(Railfrog::Transform::MarukuTransformer.new, Mime::MARKDOWN, Mime::HTML)
tm.register(Railfrog::Transform::RedClothTransformer.new, Mime::TEXTILE, Mime::HTML)


module Railfrog

#  Global config options: can be set in environment.rb
#  mattr_accessor :config_param
#  self.config_param = "config_value"

  mattr_accessor :xinha_enabled
  self.xinha_enabled = false


  if not Railfrog.const_defined? :XINHA_RUNNER_SCRIPT
    XINHA_RUNNER_SCRIPT =<<END_OF_SCRIPT
        //
        // the code snippet got from the http://xinha.gogo.co.nz/punbb/viewtopic.php?id=651
        //

        // array for editors
        xinha_editors = new Array();

        // array for plugins
        xinha_editors_plugins = new Array();

        var xinha_text_area = 'XinhaTextArea';
        // make it a new element in the xinha_editors-array
        xinha_editors.push(xinha_text_area);

        // also in the plugins-array
        xinha_editors_plugins.push(xinha_text_area);
        xinha_editors_plugins[xinha_text_area] = [
          'CharacterMap', 'ContextMenu', 'FullScreen',
          'ListType', 'SpellChecker', 'Stylist',
          'SuperClean', 'TableOperations'];

        // make the editors
        xinha_editors   = HTMLArea.makeEditors(xinha_editors, xinha_config);

        // set the plugins for the editors
        xinha_editors[xinha_text_area].registerPlugins(xinha_editors_plugins[xinha_text_area]);

        // show the editor
        HTMLArea.startEditors(xinha_editors);
END_OF_SCRIPT
  end
end

Symbol.send :include, Railfrog::SymbolExtension

