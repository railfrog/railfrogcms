require 'railfrog/transform/transform_manager'
require 'railfrog/transform/base_transformer'
require 'railfrog/transform/maruku_transformer'  # TODO add BlueCloth also
require 'mime_type_tools'  # FIXME move to Railfrog::Mime namespace

MimeTypeTools.lazy_load
tm = Railfrog::Transform::TransformManager.instance
tm.register(Railfrog::Transform::MarukuTransformer.new, Mime::MARKDOWN, Mime::HTML)

module Railfrog
end
