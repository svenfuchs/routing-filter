# The Uuid filter extracts an UUID segment from the beginning of the recognized
# path and exposes the page parameter as params[:page]. When a path is generated
# the filter adds the segments to the path accordingly if the page parameter is
# passed to the url helper.
#
#   incoming url: /d00fbbd1-82b6-4c1a-a57d-098d529d6854/product/1
#   filtered url: /product/1
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
#   product_path(:uuid => uuid)
#   url_for(product, :uuid => uuid)

module RoutingFilter
  class Uuid < Filter
    UUID_SEGMENT = %r(^/?([a-z\d]{8}\-[a-z\d]{4}\-[a-z\d]{4}\-[a-z\d]{4}\-[a-z\d]{12})/)
    
    def around_recognize(path, env, &block)
      uuid = extract_uuid!(path)
      yield.tap do |params|
        params[:uuid] = uuid if uuid
      end
    end

    def around_generate(*args, &block)
      uuid = args.extract_options!.delete(:uuid)
      yield.tap do |result|
        prepend_uuid!(result, uuid) if uuid
      end
    end

    protected

      def extract_uuid!(path)
        path.sub!(UUID_SEGMENT, '/')
        $1
      end

      def prepend_uuid!(result, uuid)
        url = result.is_a?(Array) ? result.first : result
        url.sub!(%r(^(http.?://[^/]*)?(.*))) { "#{$1}/#{uuid}#{$2}" }
      end
  end
end