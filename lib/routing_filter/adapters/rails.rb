require 'action_dispatch'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/hash/reverse_merge'
require 'routing_filter/result_wrapper'

ActionDispatch::Routing::Mapper.class_eval do
  def filter(*args)
    @set.add_filters(*args)
  end
end

module ActionDispatchRoutingRouteSetWithFiltering
  def filters
    @set.filters if @set
  end

  def add_filters(*names)
    options = names.extract_options!
    names.each { |name| filters.unshift(RoutingFilter.build(name, options)) }
  end

  def generate(route_key, options, recall = {})
    options = options.symbolize_keys

    filters.run(:around_generate, options, &lambda {
      RoutingFilter::ResultWrapper.new(super(route_key, options, recall))
    }).generate
  end

  def clear!
    filters.clear if filters
    super
  end
end

ActionDispatch::Routing::RouteSet.prepend ActionDispatchRoutingRouteSetWithFiltering

ActionDispatch::Journey::Routes.class_eval do
  def filters
    @filters ||= RoutingFilter::Chain.new.tap { |f| @filters = f unless frozen? }
  end
end

require 'routing_filter/adapters/routers/journey'
