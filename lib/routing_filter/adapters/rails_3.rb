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

  def recognize_path_with_filtering(path, env = {})
    @set.filters.run(:around_recognize, path, env, &lambda{ recognize_path_without_filtering(path, env) })
  end
  alias_method_chain :recognize_path, :filtering

  def generate_with_filtering(*args)
    @set.filters.run(:around_generate, args.first, &lambda{ generate_without_filtering(*args) })
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
    @filters ||= RoutingFilter::Chain.new
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

  def recognize_with_filtering(request, &block)
    filters.run(:around_recognize, request.env['PATH_INFO'], {}, &lambda{ recognize_without_filtering(request, &block) })
  end
end

