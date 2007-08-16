require 'railfrog/transform/transform_manager'
require 'railfrog/transform/base_transformer'
require 'railfrog/transform/maruku_transformer'
require 'railfrog/mime_type/tools'

Railfrog::MimeType::Tools.lazy_load
tm = Railfrog::Transform::TransformManager.instance
tm.register(Railfrog::Transform::MarukuTransformer.new, Mime::MARKDOWN, Mime::MARKDOWN)

module Railfrog
end
