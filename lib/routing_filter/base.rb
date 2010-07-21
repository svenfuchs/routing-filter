module RoutingFilter
  class Base
    attr_accessor :next, :previous, :options
    
    def initialize(options = {})
      @options = options
    end

    def run(method, *args, &block)
      _next = self.next ? lambda { self.next.run(method, *args, &block) } : block
      active ? send(method, *args, &_next) : _next.call(*args)
    end

    def run_reverse(method, *args, &block)
      _prev = previous ? lambda { previous.run_reverse(method, *args, &block) } : block
      active ? send(method, *args, &_prev) : _prev.call(*args)
    end
  end
end