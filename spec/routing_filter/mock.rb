module RoutingFilter
  class Mock < Base
    def around_recognize(*args, &block)
      yield
    end
    
    def around_generate(*args, &block)
      yield
    end
  end
end