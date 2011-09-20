require 'action_dispatch'
require 'rack/mount/route_set'
require 'rack/mount/code_generation'

Rack::Mount::RouteSet.class_eval do
  def filters
    @filters || RoutingFilter::Chain.new.tap { |f| @filters = f unless frozen? }
  end
end

# gah. so who's hoped monkeypatching optimized code wouldn't be necessary with rails 3 anymore?
Rack::Mount::CodeGeneration.class_eval do
  def optimize_recognize_with_filtering!
    optimize_recognize_without_filtering!
    (class << self; self; end).class_eval do
      alias_method_chain :recognize, :filtering
    end
  end
  alias :optimize_recognize_without_filtering! :optimize_recognize!
  alias :optimize_recognize! :optimize_recognize_with_filtering!

  # note: if you overly and unnecessarily use blocks in your lowlevel libraries you make it fricking
  # hard for your users to hook in anywhere
  def recognize_with_filtering(request, &block)
    path, route, matches, params = request.env['PATH_INFO'], nil, nil, nil
    original_path = path.dup

    filters.run(:around_recognize, path, request.env) do
      route, matches, params = recognize_without_filtering(request)
      params || {}
    end

    request.env['PATH_INFO'] = original_path # hmm ...
    return nil unless route

    if block_given?
      return block.call(route, matches, params)
    else
      return route, matches, params
    end
  end
end
