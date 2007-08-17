require 'railfrog/transform/transform_manager'
require 'railfrog/transform/base_transformer'
require 'railfrog/transform/maruku_transformer'  # TODO add BlueCloth also
require 'mime_type_tools'  # FIXME move to Railfrog::Mime namespace

MimeTypeTools.lazy_load
tm = Railfrog::Transform::TransformManager.instance
tm.register(Railfrog::Transform::MarukuTransformer.new, Mime::MARKDOWN, Mime::HTML)


module Railfrog

  mattr_accessor :config_param

  self.config_param = "config_value"

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