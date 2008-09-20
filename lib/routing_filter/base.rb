module RoutingFilter
  class Base
    attr_reader :options
    
    def initialize(options)
      @options = options
    end
    
    def around_recognize(*args, &block)
      yield
    end
    
    def around_generate(*args, &block)
      yield
    end
  end
end