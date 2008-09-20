module RoutingFilter
  class Base
    attr_reader :options
    
    def initialize(options)
      @options = options
    end
    
    def around_recognition(route, path, env, &block)
      yield path, env
    end
    
    def around_generation(controller, options, &block)
      yield options
    end
  end
end