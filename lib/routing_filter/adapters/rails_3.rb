require 'action_dispatch'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/hash/reverse_merge'

[ActionDispatch::Routing::Mapper, ActionDispatch::Routing::DeprecatedMapper].each do |mapper|
  mapper.class_eval do
    def filter(*args)
      @set.add_filters(*args)
    end
  end
end

ActionDispatch::Routing::RouteSet.class_eval do
  def add_filters(*names)
    options = names.extract_options!
    names.each { |name| @set.filters << RoutingFilter.build(name, options) }
  end

  # def recognize_path_with_filtering(path, env = {})
  #   @set.filters.run(:around_recognize, path.dup, env, &lambda{ recognize_path_without_filtering(path.dup, env) })
  # end
  # alias_method_chain :recognize_path, :filtering

  def generate_with_filtering(options, recall = {}, extras = false)
    @set.filters.run(:around_generate, options, &lambda{ generate_without_filtering(options, recall, extras) })
  end
  alias_method_chain :generate, :filtering

  def clear_with_filtering!
    @set.filters.clear if @set
    clear_without_filtering!
  end
  alias_method_chain :clear!, :filtering
end

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
    block.call(route, matches, params) if route
  end
end

