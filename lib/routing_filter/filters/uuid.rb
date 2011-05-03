# The Uuid filter extracts an UUID segment from the beginning of the recognized
# path and exposes the page parameter as params[:page]. When a path is generated
# the filter adds the segments to the path accordingly if the page parameter is
# passed to the url helper.
#
#   incoming url: /d00fbbd1-82b6-4c1a-a57d-098d529d6854/products
#   filtered url: /products
#   params:       params[:uuid] = 'd00fbbd1-82b6-4c1a-a57d-098d529d6854'
#
# You can install the filter like this:
#
#   # in config/routes.rb
#   Rails.application.routes.draw do
#     filter :uuid
#   end
#
# To make your named_route helpers or url_for add the uuid segment you can use:
#
#   products_path(:uuid => uuid)
#   url_for(:products, :uuid => uuid)

module RoutingFilter
  class Uuid < Filter
    UUID_SEGMENT = %r(^/?([a-z\d]{8}\-[a-z\d]{4}\-[a-z\d]{4}\-[a-z\d]{4}\-[a-z\d]{12})(/)?)
    
    def around_recognize(path, env, &block)
      uuid = extract_segment!(UUID_SEGMENT, path)
      yield.tap do |params|
        params[:uuid] = uuid if uuid
      end
    end

    def around_generate(params, &block)
      uuid = params.delete(:uuid)
      yield.tap do |result|
        prepend_segment!(result, uuid) if uuid
      end
    end
  end
end
