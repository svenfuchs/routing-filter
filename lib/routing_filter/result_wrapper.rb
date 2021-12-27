module RoutingFilter
  class ResultWrapper
    RouteWithParams = Struct.new(:url, :params) do
      def path(_)
        url
      end
    end

    attr_reader :url, :params

    def initialize(result)
      @url = result.path(nil)
      @params = result.params
    end

    def update(url)
      @url = url
    end

    def generate
      RouteWithParams.new(url, params)
    end
  end
end
