# The Pagination filter extracts segments matching /page/:page from the end of
# the recognized url and exposes the page parameter as params[:page]. When a
# url is generated the filter adds the segments to the url accordingly if the
# page parameter is passed to the url helper.
#
#   incoming url: /products/page/1
#   filtered url: /products
#   params:       params[:page] = 1
#
# You can install the filter like this:
#
#   # in config/routes.rb
#   Rails.application.routes.draw do
#     filter :pagination
#   end
#
# To make your named_route helpers or url_for add the pagination segments you
# can use:
#
#   products_path(:page => 1)
#   url_for(:products, :page => 1)

module RoutingFilter
  class Pagination < Filter
    PAGINATION_SEGMENT = %r(/page/([\d]+)/?$)

    def around_recognize(path, env, &block)
      page = extract_segment!(PAGINATION_SEGMENT, path)
      yield.tap do |params|
        params[:page] = page if page
      end
    end

    def around_generate(params, &block)
      page = params.delete(:page)
      yield.tap do |result|
        append_segment!(result, "page/#{page}") if append_page?(page)
      end
    end

    protected

      def append_page?(page)
        page && page.to_i != 1
      end
  end
end
