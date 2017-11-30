# The Prefix filter extracts segments matching /:prefix from the beginning of
# the recognized path and exposes the page parameter as params[:prefix]. When a
# path is generated the filter adds the segments to the path accordingly if
# the page parameter is passed to the url helper.
#
#   incoming url: /prefix/products
#   filtered url: /products
#   params:       params[:prefix] = 'prefix'
#
# You can install the filter like this:
#
#   # in config/routes.rb
#   Rails.application.routes.draw do
#     filter :prefix
#   end
#
# can use:
#
#   products_path makes /prefix/products/ if a prefix exists

module RoutingFilter
  class Prefix < Filter
    attr_reader :exclude

    def initialize(*args)
      super
      @exclude = options[:exclude]
      @prefix = nil
    end

    def around_recognize(path, env, &block)
      @prefix = extract_segment!(self.class.prefixes_pattern, path)

      yield.tap do |params|
        params[:prefix] = @prefix unless @prefix.nil?
      end
    end

    def around_generate(*args, &block)
      yield.tap do |result|        
        url = result.is_a?(Array) ? result.first : result

        prepend_segment!(result, @prefix) if !@prefix.nil? && !excluded?(url)
      end
    end

    class << self
      def prefixes=(prefixes)
        @@prefixes = prefixes
      end

      def prefixes
        @@prefixes ||= []
      end

      def prefixes_pattern
        @@prefixes_pattern ||=
          %r(^/(#{self.prefixes.map { |prefix| Regexp.escape(prefix.to_s) }.join('|')})(?=/|$))
      end
    end

    protected
    
    def excluded?(url)
      case exclude
      when Regexp
        url =~ exclude
      when Proc
        exclude.call(url)
      end
    end
  end
end
