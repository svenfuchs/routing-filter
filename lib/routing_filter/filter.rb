module RoutingFilter
  class Filter
    attr_accessor :next, :previous, :options

    def initialize(options = {})
      @options = options
    end

    def run(method, *args, &block)
      _next = self.next ? proc {|path, env| self.next.run(method, *args, &block) } : block
      RoutingFilter.active? ? send(method, *args, &_next) : _next.call(*args)
    end

    def run_reverse(method, *args, &block)
      _prev = previous ? lambda { previous.run_reverse(method, *args, &block) } : block
      RoutingFilter.active? ? send(method, *args, &_prev) : _prev.call(*args)
    end

    protected

      def extract_segment!(pattern, path)
        path.sub!(pattern) { $2 || '' }
        path.replace('/') if path.empty?
        $1
      end

      def prepend_segment!(result, segment)
        url = result.is_a?(Array) ? result.first : result
        url.sub!(%r(^(http.?://[^/]*)?(.*))) { "#{$1}/#{segment}#{$2 == '/' ? '' : $2}" }
      end

      def append_segment!(result, segment)
        url = result.is_a?(Array) ? result.first : result
        url.sub!(%r(/?($|\?))) { "/#{segment}#{$1}" }
      end
  end
end